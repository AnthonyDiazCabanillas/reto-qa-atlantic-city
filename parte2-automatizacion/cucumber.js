module.exports = {
  default: {
    paths: ["src/features/**/*.feature"],
    require: ["src/support/**/*.ts", "src/steps/**/*.ts"],
    requireModule: ["ts-node/register"],
    format: [
      "progress-bar",
      "html:reports/cucumber-report.html",
      "json:reports/cucumber-report.json"
    ],
    formatOptions: { snippetInterface: "async-await" },
    // 1 reintento solo en CI
    retry: Number(process.env.RETRY ?? (process.env.CI ? 1 : 0)),
    parallel: 1
  }
};
