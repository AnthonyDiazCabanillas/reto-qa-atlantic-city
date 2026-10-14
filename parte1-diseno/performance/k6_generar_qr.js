/**
 * Pregunta 6 - Script de referencia en k6 para "Pago con QR".
 *
 * IMPORTANTE: los endpoints (/api/...) son SUPUESTOS para ilustrar el diseño.
 * Se reemplazan por los reales tras revisar la API (DevTools / equipo de desarrollo).
 * Ejecutar SOLO contra un ambiente de performance / sandbox, nunca contra producción.
 *
 * Uso:
 *   k6 run -e TIPO=carga   -e BASE_URL=https://qa.ejemplo.com k6_generar_qr.js
 *   k6 run -e TIPO=estres  ...
 *   k6 run -e TIPO=pico    ...
 */
import http from "k6/http";
import { check, group, sleep } from "k6";
import { Trend, Counter } from "k6/metrics";
import { SharedArray } from "k6/data";

const BASE_URL = __ENV.BASE_URL || "https://qa.ejemplo.com";

// Pool de usuarios de prueba (no uno solo): evita bloqueos de sesión y cachés irreales.
const usuarios = new SharedArray("usuarios", () =>
  Array.from({ length: 200 }, (_, i) => ({ user: `perf_user_${i + 1}`, pass: __ENV.PERF_PASSWORD }))
);

// Distribución de montos según el modelo de carga (P6 §3)
const MONTOS = [
  ...Array(40).fill(10),
  ...Array(35).fill(100),
  ...Array(15).fill(300),
  ...Array(10).fill(250) // "Otro monto"
];

const tiempoGenerarQR = new Trend("tiempo_generar_qr", true);
const qrFallidos = new Counter("qr_fallidos");

const PERFILES = {
  // Carga: rampa al 100 % del pico y se sostiene 30 min
  carga: {
    executor: "ramping-arrival-rate",
    startRate: 1, timeUnit: "1s", preAllocatedVUs: 50, maxVUs: 300,
    stages: [
      { duration: "5m", target: 6 },   // ~6 depósitos/s (supuesto de pico)
      { duration: "30m", target: 6 },
      { duration: "2m", target: 0 }
    ]
  },
  // Estrés: escalones de +25 % cada 5 min hasta encontrar el punto de quiebre.
  // Se mide por minuto porque k6 solo acepta targets enteros (6/s = 360/min, +25 % = 450/min...)
  estres: {
    executor: "ramping-arrival-rate",
    startRate: 360, timeUnit: "1m", preAllocatedVUs: 100, maxVUs: 2000,
    stages: [360, 450, 540, 630, 720, 900, 1080, 1440, 1800].flatMap((t) => [
      { duration: "1m", target: t },
      { duration: "4m", target: t }
    ])
  },
  // Pico: de 100 % a 300 % en 30 s y vuelta a la normalidad (¿se recupera?)
  pico: {
    executor: "ramping-arrival-rate",
    startRate: 6, timeUnit: "1s", preAllocatedVUs: 100, maxVUs: 1000,
    stages: [
      { duration: "5m", target: 6 },
      { duration: "30s", target: 18 },
      { duration: "5m", target: 18 },
      { duration: "30s", target: 6 },
      { duration: "10m", target: 6 }
    ]
  }
};

export const options = {
  scenarios: { deposito_qr: PERFILES[__ENV.TIPO || "carga"] },
  // SLA del reto: si no se cumple, k6 termina con código de error (útil en CI)
  thresholds: {
    tiempo_generar_qr: ["p(95)<3000", "p(99)<5000"],
    http_req_failed: ["rate<0.01"],
    checks: ["rate>0.99"]
  }
};

export default function () {
  const u = usuarios[(__VU - 1) % usuarios.length];
  const monto = MONTOS[Math.floor(Math.random() * MONTOS.length)];

  let token;
  group("T1 - Login", () => {
    const res = http.post(`${BASE_URL}/api/auth/login`, JSON.stringify({ user: u.user, password: u.pass }), {
      headers: { "Content-Type": "application/json" },
      tags: { transaccion: "login" }
    });
    check(res, { "login 200": (r) => r.status === 200 });
    token = res.json("token");
  });
  if (!token) return;

  const auth = { headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" } };
  sleep(Math.random() * 5 + 3); // tiempo de pensamiento 3-8 s

  group("T3 - Generar QR", () => {
    const res = http.post(`${BASE_URL}/api/depositos/qr`, JSON.stringify({ monto, moneda: "PEN" }), {
      ...auth,
      tags: { transaccion: "generar_qr" }
    });
    tiempoGenerarQR.add(res.timings.duration);
    const ok = check(res, {
      "QR 201/200": (r) => r.status === 201 || r.status === 200,
      "QR trae imagen o código": (r) => !!r.json("qr"),
      "estado Pendiente": (r) => r.json("estado") === "Pendiente",
      "monto correcto": (r) => Number(r.json("monto")) === monto
    });
    if (!ok) qrFallidos.add(1);
  });

  sleep(Math.random() * 5 + 3);
}
