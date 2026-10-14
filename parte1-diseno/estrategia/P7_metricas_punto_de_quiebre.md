# P7 - Métricas para determinar el punto de quiebre

El punto de quiebre es la carga a partir de la cual el sistema deja de cumplir los tiempos o empieza a fallar. Lo encuentro con la prueba de estrés por escalones de la P6: subo la carga de a pocos y veo en qué escalón se rompen las métricas.

Lo que normalmente se observa es esto:

- Los tiempos se mantienen estables.
- Luego empiezan a subir.
- Al final se disparan, junto con los errores.
- El throughput deja de crecer aunque agregue más usuarios.

## Del lado del usuario (k6 / JMeter)

- **Tiempo de respuesta p95 y p99:** no me fijo en el promedio porque esconde a los usuarios más lentos. La señal de quiebre es que el p95 de "Generar QR" pase de 3 s.
- **Tasa de error:** respuestas 5xx, timeouts o validaciones fallidas. La señal es que supere el 1 %.
- **Throughput (depósitos por segundo):** la señal es que se estanque o baje aunque suba la carga.
- **Usuarios concurrentes:** es el valor que reporto como punto de quiebre.
- **Timeouts:** cuando empiezan a aparecer y a crecer.

## Del lado del servidor

- CPU por encima del 80-85 % sostenido.
- Memoria que sube y no baja, o pausas largas del garbage collector.
- Pool de conexiones o de hilos agotado, con peticiones en cola.
- Colas de mensajes (si los callbacks usan una) que crecen más rápido de lo que se procesan.

## Base de datos (SQL Server)

- Consultas a `Depositos` cada vez más lentas (posible falta de índices).
- Bloqueos y deadlocks al insertar o actualizar depósitos al mismo tiempo.
- Conexiones activas llegando al máximo.
- Aumento de los wait stats (esperas de I/O o de bloqueos).

## Pasarela

- Latencia de la pasarela al generar el QR, que es lo que más pesa en los 3 s.
- Errores o rate limit del proveedor (HTTP 429).
- Callbacks que tardan y dejan depósitos en "Pendiente" mucho tiempo.

## Negocio, que para mí es lo más importante

Que el sistema responda no basta: hay que confirmar que no se pierde ni se duplica plata. Al terminar cada prueba reviso con SQL que haya:

- Cero depósitos duplicados.
- Cero pagos confirmados por la pasarela que no se acreditaron.
- Cero depósitos atascados en "Pendiente" después de la vigencia del QR.
- Diferencia cero en la conciliación entre el casino y la pasarela.

## Cómo lo reportaría

Un ejemplo de redacción del informe:

> Hasta N usuarios concurrentes el sistema cumple el SLA (p95 de 2.1 s y 0.2 % de errores). Con N + 25 %, el p95 sube a 4.8 s y los errores al 6 %, y el throughput se estanca en X depósitos por segundo. Según el APM, la causa es que se agota el pool de conexiones a SQL Server. El punto de quiebre está en N + 25 % usuarios y recomiendo operar hasta N usuarios, que es alrededor del 80 % del quiebre.
