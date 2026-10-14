# P4 - Herramientas

Estas son las herramientas que usaría para las estrategias de la P3:

- **Jira + Xray:** para gestionar casos, ejecuciones y defectos, con trazabilidad entre la historia, el caso y el bug.
- **Playwright + Cucumber (TypeScript):** para las pruebas E2E de UI y la regresión. Es lo que usé en la P10.
- **Postman / Newman y Karate:** Postman para explorar la API, Newman para correr las colecciones en el pipeline y Karate para la suite de API en BDD.
- **WireMock o Mockoon:** para simular la pasarela (timeout, error 500, callback duplicado, QR expirado) sin depender del proveedor.
- **SQL Server Management Studio:** para validar los registros, los estados y la conciliación.
- **k6 (o JMeter):** para las pruebas de performance. Prefiero k6 porque los scripts son en JavaScript, son livianos y se integran fácil al CI.
- **Grafana / Prometheus o un APM (Datadog, New Relic):** para ver CPU, memoria, conexiones a la BD y tiempos por servicio mientras corre la carga.
- **OWASP ZAP y Burp Suite:** ZAP para el escaneo automático y Burp para interceptar requests y modificar el monto o el id del depósito.
- **Chrome DevTools:** para revisar los requests, simular red lenta u offline y ver los errores de consola.
- **BrowserStack o dispositivos reales:** para compatibilidad en Android e iOS y para probar el escaneo del QR con billeteras reales.
- **axe / Lighthouse:** para accesibilidad y tiempos de carga de la página.
- **GitHub Actions (o Jenkins / Azure DevOps):** para ejecutar el smoke y la regresión en cada cambio.
- **Reporte de Cucumber, Allure y el trace de Playwright:** como evidencia de cada ejecución.
- **Git / GitHub:** para versionar el código de pruebas.
