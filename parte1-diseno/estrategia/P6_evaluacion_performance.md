# P6 - Propuesta de evaluación de performance

## Objetivo

Validar que la generación del QR y la confirmación del depósito respondan a tiempo con la carga esperada, y encontrar hasta cuánta carga aguanta el sistema y qué componente falla primero.

## Qué mediría

- **Login:** p95 menor a 2 s.
- **Abrir DEPOSITAR y listar métodos:** p95 menor a 1 s.
- **Generar QR:** p95 menor a 3 s. Es el requisito del reto y la transacción más importante.
- **Consultar el estado del depósito:** p95 menor a 500 ms.
- **Callback de la pasarela y acreditación:** p95 menor a 1 s y cero duplicados.

El rendimiento propio de Yape o Plin queda fuera del alcance. En las pruebas de estrés simularía la pasarela con un mock para no saturar al proveedor.

## Modelo de carga

Lo ideal es sacarlo de los datos de producción (analytics, logs, APM). Como el reto no los da, asumiría:

- Hora pico de unos 1 200 depósitos por hora, es decir unos 20 por minuto.
- Montos repartidos así: S/10 (40 %), S/100 (35 %), S/300 (15 %) y "Otro monto" (10 %).
- Pausas de 3 a 8 s entre pasos, para simular a un usuario real.
- Varios usuarios de prueba distintos, no uno solo.

## Tipos de prueba

1. **Línea base:** 1 a 5 usuarios durante 10 min, para tener la referencia.
2. **Carga:** subir hasta el 100 % del pico y mantenerlo 30 min.
3. **Estrés:** subir un 25 % cada 5 min hasta que el sistema se rompa. De aquí sale el punto de quiebre.
4. **Picos:** pasar del 100 % al 300 % en 30 s (como cuando sale una promoción) y ver si el sistema se recupera.
5. **Resistencia:** 70 % del pico durante 4 a 8 horas, para detectar fugas de memoria o de conexiones.
6. **Concurrencia:** el mismo usuario con varias peticiones a la vez y el callback duplicado, para confirmar que se genera un solo QR y se acredita una sola vez.

## Ambiente

- Un ambiente lo más parecido posible a producción (mismo tamaño de servidores y una BD con volumen real).
- Los generadores de carga fuera de los servidores que se prueban.
- APM, Grafana y monitoreo de SQL Server activos durante la ejecución.

## Herramienta

Usaría k6. Dejé un script de ejemplo en `../performance/k6_generar_qr.js` con los perfiles de carga, estrés y picos, y los umbrales de p95 menor a 3 s y errores menores al 1 %. Los endpoints del script son supuestos y habría que reemplazarlos por los reales.

## Cómo lo ejecutaría

1. Validar el script con 1 usuario.
2. Correr la línea base.
3. Correr la carga y analizar.
4. Correr el estrés hasta el quiebre y ubicar el cuello de botella con el APM.
5. Correr los picos y la resistencia.
6. Después de las mejoras de desarrollo, repetir y comparar con la línea base.

## Criterios para aprobar

- Generar QR con p95 menor a 3 s en la carga pico.
- Errores por debajo del 1 %.
- CPU por debajo del 70-75 % sostenido en la carga pico.
- Cero depósitos duplicados y cero pagos sin acreditar (lo valido con SQL al final).
- Después de un pico, el sistema vuelve a los tiempos normales en menos de 5 min.

## Entregable

Un informe con el resultado (pasa o no pasa), las gráficas de tiempo de respuesta, throughput y errores, el punto de quiebre, el cuello de botella encontrado y las recomendaciones. Por ejemplo: un índice en `Depositos(UsuarioId, Estado, FechaCreacion)`, ajustar el pool de conexiones o revisar los timeouts hacia la pasarela.
