# Parte 2 (Pregunta 10): Automatización del login

Stack: **Playwright + Cucumber (BDD) + TypeScript**, con Page Object Model.

## Pasos del reto y dónde están en el código

| Paso del reto | Dónde |
|---|---|
| a. Abrir el navegador con la URL del casino | `BeforeAll` en `src/support/hooks.ts` + paso *"que el usuario abre la página del casino"* |
| b. Clic en "Iniciar sesión" de la cabecera | `HomePage.clickHeaderLogin()` |
| c. Ingresar usuario y contraseña | `LoginModal.fillCredentials()`. Los valores vienen de `.env` |
| d. Clic en "Iniciar sesión" | `LoginModal.submit()` |
| e. Cerrar el navegador | `AfterAll` en `src/support/hooks.ts` |
| (extra) Validar que inició sesión | El modal se cierra, desaparece el botón de login y aparece **DEPOSITAR** |

## Requisitos

Node.js 18 o superior.

## Ejecución

```bash
cd parte2-automatizacion
npm install
npx playwright install chromium
copy env.example .env        # Windows   (Mac/Linux: cp env.example .env)
npm test                     # todos los escenarios
npm run test:visual          # con navegador visible y en cámara lenta
npm run test:chrome          # con el Google Chrome instalado
npm run test:smoke           # solo @smoke
```

Reporte: `reports/cucumber-report.html`, con una captura por paso. Si un escenario falla, se guarda un trace en `reports/traces/`, que se abre con `npx playwright show-trace <archivo.zip>`.

## Decisiones técnicas

- **Selectores verificados en el sitio real.** El botón del header es `button#login`. Su texto cambia según el ancho de pantalla: "INICIAR SESIÓN" en escritorio e "INGRESAR" en móvil. Por eso se usa el `id` y no el texto. Los campos se ubican por `name="user"` y `name="password"`, porque los `id` de Material UI (`:r2:`) se generan dinámicamente.
- **Credenciales fuera del código.** Se leen de `.env` (ignorado por Git) o de GitHub Secrets en CI. Si faltan, la prueba falla con un mensaje claro.
- **Sin esperas fijas (`waitForTimeout`).** Se usan las esperas automáticas de Playwright y aserciones `expect` con reintento.
- **Aislamiento.** Cada escenario tiene un contexto de navegador nuevo, sin cookies ni sesión previas, a través del `World` de Cucumber, sin variables globales.
- **Banner de cookies.** Se cierra solo si aparece, sin fallar si no está.
- **Popups de terceros bloqueados.** En la primera ejecución apareció un popup promocional de Optimove encima del modal de login y bloqueó los clics. Se bloquean por red (`context.route`) los dominios de marketing, chat y pruebas A/B. No se bloquea el antifraude ni nada del propio casino. Se desactiva con `BLOCK_THIRD_PARTY=false`.
- **Fallo con el motivo real.** Si el sitio rechaza el login, la prueba falla mostrando el mensaje del sitio y no un timeout genérico.
- **Evidencia.** Captura en cada paso y trace solo en los fallos.
- **CI.** Pipeline en `.github/workflows/e2e.yml`: se ejecuta en cada push a `main`, toma las credenciales de GitHub Secrets (`CASINO_USER` y `CASINO_PASSWORD`) y publica los reportes como artifact. Hace 1 reintento en CI porque el sitio es público y puede tener fallos de red.

## Hallazgo en la ejecución real

Al ejecutar con las credenciales del reto, el sitio respondió: *"Para tu seguridad y debido al máximo de intentos fallidos, es necesario restablecer tu contraseña."* La cuenta de prueba `Testcalimaco35` está **bloqueada por intentos fallidos**, probablemente porque la comparten varios postulantes. No se restableció la contraseña porque la cuenta es compartida y no es propia; se reportó al equipo evaluador, que entregó las cuentas alternativas `Testcalimaco34` y `Testcalimaco36`. Basta con cambiar `CASINO_USER` y `CASINO_PASSWORD` en `.env`, sin tocar el código: esa es la ventaja de no escribir las credenciales en el código. La automatización también detecta este caso y lo informa con claridad.
