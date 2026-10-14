import { Given, Then, When } from "@cucumber/cucumber";
import { expect } from "@playwright/test";
import { config } from "../support/config";
import { CustomWorld } from "../support/world";

Given("que el usuario abre la página del casino", async function (this: CustomWorld) {
  await this.home.open();
});

When('hace clic en {string} de la cabecera', async function (this: CustomWorld, _boton: string) {
  await this.home.clickHeaderLogin();
  await this.login.waitUntilVisible();
});

When("ingresa su nombre de usuario y contraseña", async function (this: CustomWorld) {
  await this.login.fillCredentials(config.user(), config.password());
});

When('hace clic en el botón {string} del formulario', async function (this: CustomWorld, _boton: string) {
  await expect(this.login.submitButton).toBeEnabled();
  await this.login.submit();
});

Then("la sesión se inicia correctamente", async function (this: CustomWorld) {
  // espera lo que salga primero: DEPOSITAR o el mensaje de error del sitio
  await expect(this.home.depositButton.or(this.login.errorMessage).first()).toBeVisible({ timeout: 20_000 });
  if (await this.login.errorMessage.isVisible()) {
    throw new Error(`El sitio rechazó el inicio de sesión: "${await this.login.getErrorText()}"`);
  }
  await expect(this.login.userInput).toBeHidden();
  await expect(this.home.headerLoginButton).toBeHidden();
  await expect(this.home.depositButton).toBeVisible();
});

Then('el botón {string} del formulario está deshabilitado', async function (this: CustomWorld, _boton: string) {
  await expect(this.login.userInput).toBeEmpty();
  await expect(this.login.passwordInput).toBeEmpty();
  await expect(this.login.submitButton).toBeDisabled();
});
