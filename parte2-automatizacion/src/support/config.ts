import * as dotenv from "dotenv";

dotenv.config();

function required(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(
      `Falta la variable de entorno ${name}. Copia env.example como .env y complétala (o defínela como secret en CI).`
    );
  }
  return value;
}

export const config = {
  baseUrl: process.env.BASE_URL ?? "https://www.casinoatlanticcity.com/",
  user: () => required("CASINO_USER"),
  password: () => required("CASINO_PASSWORD"),
  browser: (process.env.BROWSER ?? "chromium") as "chromium" | "firefox" | "webkit",
  channel: process.env.CHANNEL,
  headless: process.env.HEADLESS ? process.env.HEADLESS === "true" : !!process.env.CI,
  slowMo: Number(process.env.SLOWMO ?? 0),
  blockThirdParty: process.env.BLOCK_THIRD_PARTY !== "false",
  timeouts: {
    step: 60_000,
    action: 15_000,
    navigation: 45_000
  }
};
