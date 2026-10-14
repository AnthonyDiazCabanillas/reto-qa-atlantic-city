import { Locator, Page } from "@playwright/test";

export class LoginModal {
  readonly dialog: Locator;
  readonly userInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly errorMessage: Locator;

  constructor(page: Page) {
    this.dialog = page.getByRole("dialog");
    const form = this.dialog.locator("form");
    // por name, los id de MUI (:r2:) cambian en cada carga
    this.userInput = form.locator('input[name="user"]');
    this.passwordInput = form.locator('input[name="password"]');
    this.submitButton = form.getByRole("button", { name: /iniciar sesi[oó]n/i });
    // ej: "...máximo de intentos fallidos, es necesario restablecer tu contraseña"
    this.errorMessage = form.getByText(/intentos fallidos|incorrect|inv[aá]lid|bloquead/i).first();
  }

  async getErrorText(): Promise<string> {
    return ((await this.errorMessage.innerText().catch(() => "")) || "").trim();
  }

  async waitUntilVisible(): Promise<void> {
    await this.userInput.waitFor({ state: "visible" });
  }

  async fillCredentials(user: string, password: string): Promise<void> {
    await this.userInput.fill(user);
    await this.passwordInput.fill(password);
  }

  async submit(): Promise<void> {
    await this.submitButton.click();
  }
}
