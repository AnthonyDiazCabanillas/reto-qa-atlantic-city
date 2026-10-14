# Reto Técnico: Analista QA Senior (Casino Atlantic City)

Solución al reto de QA sobre el **Depósito con la pasarela "Pago con QR"** y la automatización del **login**.

**Autor:** Anthony Diaz Cabanillas

## Índice de respuestas

### Parte 1: Diseño de pruebas, estrategia y SQL

| # | Pregunta | Respuesta |
|---|---|---|
| 1 | Casos de prueba en Gherkin (Happy, Alternative, Negative, Exception, Security y Performance) | [`deposito_pago_qr.feature`](parte1-diseno/casos-de-prueba/deposito_pago_qr.feature) |
| 2 | Etiquetado @critical / @smoke / @regression | El mismo feature: el criterio está en su encabezado |
| 3 | Estrategias de prueba funcionales y no funcionales | [`P3_estrategias_de_prueba.md`](parte1-diseno/estrategia/P3_estrategias_de_prueba.md) |
| 4 | Herramientas | [`P4_herramientas.md`](parte1-diseno/estrategia/P4_herramientas.md) |
| 5 | Técnicas de caja negra con ejemplos | [`P5_tecnicas_caja_negra.md`](parte1-diseno/estrategia/P5_tecnicas_caja_negra.md) |
| 6 | Evaluación técnica de performance | [`P6_evaluacion_performance.md`](parte1-diseno/estrategia/P6_evaluacion_performance.md) + script [`k6_generar_qr.js`](parte1-diseno/performance/k6_generar_qr.js) |
| 7 | Métricas del punto de quiebre | [`P7_metricas_punto_de_quiebre.md`](parte1-diseno/estrategia/P7_metricas_punto_de_quiebre.md) |
| 8 | SQL: depósitos Exitosos de 10 a 100 en PEN | [`P8_depositos_exitosos_10_a_100.sql`](parte1-diseno/sql/P8_depositos_exitosos_10_a_100.sql) |
| 9 | SQL: INNER JOIN Usuarios–Depositos | [`P9_depositos_pendientes_testcalimaco35.sql`](parte1-diseno/sql/P9_depositos_pendientes_testcalimaco35.sql) |

Las consultas SQL incluyen un script con el esquema y datos de prueba con valores límite ([`00_esquema_y_datos_de_prueba.sql`](parte1-diseno/sql/00_esquema_y_datos_de_prueba.sql)) para ejecutarlas y comprobar el resultado esperado.

### Parte 2: Automatización

| # | Pregunta | Respuesta |
|---|---|---|
| 10 | Login automatizado en casinoatlanticcity.com | [`parte2-automatizacion/`](parte2-automatizacion/), con Playwright + Cucumber + TypeScript. Las instrucciones están en su [README](parte2-automatizacion/README.md) |

## Estructura

```
├── parte1-diseno/
│   ├── casos-de-prueba/   P1 y P2 (Gherkin)
│   ├── estrategia/        P3 a P7
│   ├── performance/       Script k6 de referencia (P6)
│   └── sql/               P8, P9 y datos de prueba
├── parte2-automatizacion/ P10 (Playwright + Cucumber)
└── ci/                    Pipeline de GitHub Actions
```

## Ejecución rápida de la automatización

```bash
cd parte2-automatizacion
npm install
npx playwright install chromium
copy env.example .env
npm test
```

## Supuestos y observaciones de QA

- La cuenta del reto `Testcalimaco35` quedó bloqueada por intentos fallidos. El equipo evaluador entregó la cuenta alternativa **`Testcalimaco34`**, que es la que usan la automatización (`env.example`) y los casos de prueba. La consulta de la P9 mantiene `Testcalimaco35` porque así lo pide el enunciado.
- Los casos de la P1 se basan en las reglas visibles en el Anexo 1: montos S/10, S/100 y S/300, "Otro monto", mínimo S/10 y máximo S/500, y las billeteras Plin, Yape y +16. Los tiempos de vigencia del QR y los mensajes exactos de error no se indican en el reto, así que deben confirmarse con negocio.
- El esquema del Anexo 2 **no define una FOREIGN KEY** entre `Depositos.UsuarioId` y `Usuarios.IdUsuario`. Lo reporto como observación, porque permitiría depósitos "huérfanos".
- `Depositos` no tiene un campo para el ID de transacción de la pasarela. Ese campo es clave para la idempotencia (evitar la doble acreditación) y para la conciliación. Recomiendo agregarlo con un índice único.
- Los endpoints del script k6 son ilustrativos, porque la API real no forma parte del reto.
