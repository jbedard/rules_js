# `rules_js` issue #1218 reproduction

Or maybe an unrelated issue. Link https://github.com/aspect-build/rules_js/issues/1218#issuecomment-3892080323

## Reproduction steps

1. `bazel build --sandbox_debug //...` from the repo root

Output should be similar to

```
openapi-typescript failed: node:internal/modules/package_json_reader:314
  throw new ERR_MODULE_NOT_FOUND(packageName, fileURLToPath(base), null);
        ^

Error [ERR_MODULE_NOT_FOUND]: Cannot find package '@redocly/openapi-core' imported from .../65e6dcafd53adec6b1686cacaf1f8205/sandbox/linux-sandbox/39/execroot/_main/bazel-out/aarch64-opt-exec/bin/external/rules_foo+/openapi_typescript_cli_/openapi_typescript_cli.runfiles/rules_foo+/node_modules/.aspect_rules_js/openapi-typescript@7.13.0_typescript@5.9.3/node_modules/openapi-typescript/bin/cli.js
    at Object.getPackageJSONURL (node:internal/modules/package_json_reader:314:9)
    at packageResolve (node:internal/modules/esm/resolve:767:81)
    at moduleResolve (node:internal/modules/esm/resolve:853:18)
    at defaultResolve (node:internal/modules/esm/resolve:983:11)
    at #cachedDefaultResolve (node:internal/modules/esm/loader:731:20)
    at ModuleLoader.resolve (node:internal/modules/esm/loader:708:38)
    at ModuleLoader.getModuleJobForImport (node:internal/modules/esm/loader:310:38)
    at ModuleJob._link (node:internal/modules/esm/module_job:182:49) {
  code: 'ERR_MODULE_NOT_FOUND'
}

Node.js v22.22.0`
```

Inspecting

```
readlink .../65e6dcafd53adec6b1686cacaf1f8205/sandbox/linux-sandbox/39/execroot/_main/bazel-out/aarch64-opt-exec/bin/external/rules_foo+/openapi_typescript_cli_/openapi_typescript_cli.runfiles/rules_foo+/node_modules/.aspect_rules_js/openapi-typescript@7.13.0_typescript@5.9.3/node_modules/@redocly/openapi-core
../../..spect_rules_js/@redocly+openapi-core@1.34.6_supports-color@10.2.2/node_modules/@redocly/openapi-core
```

leads to odd results (what is `..spect_rules_js`?)
