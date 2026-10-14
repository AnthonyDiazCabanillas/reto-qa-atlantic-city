# P3 - Estrategias de prueba para Depósito "Pago con QR"

En un depósito se mueve dinero real y dependemos de terceros (la pasarela y las billeteras), así que yo priorizaría las pruebas por riesgo. Lo que más me preocupa es:

1. Que el saldo se acredite dos veces (por ejemplo, si la pasarela manda la confirmación duplicada).
2. Que el usuario pague y el saldo no le llegue.
3. Que se pueda reutilizar un QR o alterar el monto.
4. Que se acepten montos fuera del rango de S/10 a S/500.
5. Que el QR demore mucho en generarse o que el sistema se caiga en horas pico.

Los puntos 1 a 3 los considero críticos porque implican pérdida de dinero o fraude.

La mayor parte de las pruebas las pondría a nivel de API, porque es más rápido y estable, y dejaría la UI para los flujos principales que ve el usuario.

## Pruebas funcionales

- **Smoke:** login, DEPOSITAR, Pago con QR, elegir S/10 y que se genere el QR. Se corre en cada despliegue.
- **Funcionales del sistema:** montos rápidos, "Otro monto", límites de S/10 y S/500, botón SIGUIENTE habilitado o deshabilitado, ayuda "¿Cómo depositar?", volver atrás y cerrar.
- **API:** generar el QR con montos válidos e inválidos, sin token y con el token de otro usuario; consultar el estado del depósito; validar el contrato de la respuesta.
- **Integración con la pasarela:** generación del QR y el callback de confirmación. En QA usaría el sandbox del proveedor o un mock para simular timeouts, errores y confirmaciones duplicadas.
- **Transición de estados:** Pendiente a Exitoso, Pendiente a Fallido y QR expirado. También validaría que no ocurran cambios inválidos, como Exitoso a Pendiente.
- **Base de datos:** que cada depósito se registre con el monto, la moneda, el estado y la fecha correctos (consultas de la P8 y la P9).
- **Conciliación:** que lo que figura como Exitoso en el casino cuadre con el reporte de la pasarela.
- **Regresión:** suite automatizada de UI y API corriendo en el pipeline.
- **Exploratorias:** por ejemplo, probar el flujo con red lenta o con dos pestañas abiertas.
- **Compatibilidad:** Chrome, Edge, Safari y Firefox, en desktop y en móvil. En móvil hay que revisar cómo paga el usuario, ya que no puede escanear su propia pantalla.
- **UAT:** con negocio, usando billeteras reales y montos mínimos.

## Pruebas no funcionales

- **Performance:** carga, estrés, picos y resistencia (detalle en la P6 y la P7).
- **Seguridad:** acceso a depósitos de otro usuario cambiando el id, manipulación del monto en el request, reutilización del QR, sesión expirada, XSS en "Otro monto", rate limiting y HTTPS.
- **Resiliencia:** si la pasarela se cae o está lenta, el sistema debe mostrar un mensaje claro y no perder ni duplicar dinero.
- **Usabilidad:** mensajes claros de mínimo y máximo, y que el estado del pago y la vigencia del QR sean visibles.
- **Accesibilidad:** contraste, navegación con teclado y lector de pantalla.
- **Logs y trazabilidad:** que cada depósito tenga un id de transacción para soporte y auditoría.

## Ambientes y datos

- Pasaría por DEV, QA (con el sandbox de la pasarela) y UAT. En PROD solo smoke y monitoreo.
- Usuarios de prueba dedicados, billeteras sandbox y montos con valores límite.

## Cuándo empiezo y cuándo doy por terminado

- **Para empezar:** historia con criterios de aceptación claros, build en QA, sandbox disponible y datos listos.
- **Para cerrar:** todos los casos @critical en verde, sin defectos críticos ni altos abiertos, el QR generándose en menos de 3 s (p95) y la conciliación sin diferencias.
