import { pathToFileURL } from "node:url";

const [srcPath, ...providers] = process.argv.slice(2);

if (!srcPath || providers.length === 0) {
  console.error("usage: extract-models.mjs <models.generated.ts> <provider>...");
  process.exit(1);
}

const { MODELS } = await import(pathToFileURL(srcPath).href);

const result = { providers: {} };
for (const provider of providers) {
  const providerModels = MODELS[provider];
  if (!providerModels) continue;

  const entries = Object.values(providerModels);
  const first = entries[0];
  if (!first?.baseUrl) {
    throw new Error(`Provider ${provider} has no baseUrl in ${srcPath}`);
  }

  result.providers[provider] = {
    baseUrl: first.baseUrl,
    apiKey: "OPENCODE_API_KEY",
    models: entries.map(({ provider: _provider, ...model }) => model),
  };
}

process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
