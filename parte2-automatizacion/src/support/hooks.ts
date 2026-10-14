import { After, AfterAll, AfterStep, Before, BeforeAll, Status, setDefaultTimeout } from "@cucumber/cucumber";
import { Browser, chromium, firefox, webkit } from "@playwright/test";
import * as fs from "fs";
import { config } from "./config";
import { CustomWorld } from "./world";

setDefaultTimeout(config.timeouts.step);

let browser: Browser;
const TRACES_DIR = "reports/traces";

// popups de marketing, chat y A/B testing
const BLOCKED_THIRD_PARTY =
  /optimove\.net|zdassets\.com|zendesk\.com|hotjar\.com|clarity\.ms|convertexperiments\.com|wingify\.net/i;

BeforeAll(async function () {
  const engines = { chromium, firefox, webkit };
  browser = await engines[config.browser].launch({
    headless: config.headless,
    slowMo: config.slowMo,
    channel: config.browser === "chromium" ? config.channel : undefined
  });
});

Before(async function (this: CustomWorld) {
  this.context = await browser.newContext({
    viewport: { width: 1366, height: 768 },
    locale: "es-PE"
  });
  // el popup de Optimove tapaba el modal de login
  if (config.blockThirdParty) {
    await this.context.route(BLOCKED_THIRD_PARTY, (route) => route.abort());
  }
  this.context.setDefaultTimeout(config.timeouts.action);
  this.context.setDefaultNavigationTimeout(config.timeouts.navigation);
  await this.context.tracing.start({ screenshots: true, snapshots: true });
  this.page = await this.context.newPage();
  this.initPages();
});

AfterStep(async function (this: CustomWorld) {
  try {
    const img = await this.page.screenshot({ timeout: 10_000 });
    this.attach(img, "image/png");
  } catch {
    // si no se puede tomar la captura no se cae la prueba
  }
});

// trace solo cuando falla
After(async function (this: CustomWorld, { pickle, result }) {
  if (result?.status === Status.FAILED) {
    fs.mkdirSync(TRACES_DIR, { recursive: true });
    const file = `${TRACES_DIR}/${pickle.name.replace(/\W+/g, "_")}_${Date.now()}.zip`;
    await this.context.tracing.stop({ path: file });
    this.attach(`Trace guardado: ${file} (abrir con: npx playwright show-trace ${file})`, "text/plain");
  } else {
    await this.context.tracing.stop();
  }
  await this.context.close();
});

AfterAll(async function () {
  await browser?.close();
});
