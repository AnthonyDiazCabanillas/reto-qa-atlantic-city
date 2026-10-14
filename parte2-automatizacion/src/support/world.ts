import { IWorldOptions, World, setWorldConstructor } from "@cucumber/cucumber";
import { BrowserContext, Page } from "@playwright/test";
import { HomePage } from "../pages/HomePage";
import { LoginModal } from "../pages/LoginModal";

export class CustomWorld extends World {
  context!: BrowserContext;
  page!: Page;
  home!: HomePage;
  login!: LoginModal;

  constructor(options: IWorldOptions) {
    super(options);
  }

  initPages(): void {
    this.home = new HomePage(this.page);
    this.login = new LoginModal(this.page);
  }
}

setWorldConstructor(CustomWorld);
