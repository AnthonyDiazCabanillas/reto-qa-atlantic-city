import { Locator, Page } from "@playwright/test";
import { config } from "../support/config";

export class HomePage {
  readonly headerLoginButton: Locator;
  readonly acceptCookiesButton: Locator;
  readonly depositButton: Locator;

  constructor(private readonly page: Page) {
    // por id: el texto cambia entre desktop (INICIAR SESIÓN) y mobile (INGRESAR)
    this.headerLoginButton = page.locator("button#login");
    this.acceptCookiesButton = page.getByRole("button", { name: /aceptar cookies/i });
    this.depositButton = page.getByRole("button", { name: /depositar/i }).first();
  }

  async open(): Promise<void> {
    await this.page.goto(config.baseUrl, { waitUntil: "domcontentloaded" });
    await this.headerLoginButton.waitFor({ state: "visible" });
    await this.dismissCookiesIfPresent();
  }

  async dismissCookiesIfPresent(): Promise<void> {
    if (await this.acceptCookiesButton.isVisible().catch(() => false)) {
      await this.acceptCookiesButton.click();
    }
  }

  async clickHeaderLogin(): Promise<void> {
    await this.headerLoginButton.click();
  }
}
