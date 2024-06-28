// NOTE: keep in sync with e2e/pnpm_workspace_rerooted

const packageJson = require('./package.json')
const f = require('@aspect-test/f')
module.exports = {
    id: () =>
        `${packageJson.name}@${
            packageJson.version ? packageJson.version : '0.0.0'
        }`,
    idF: () => f.id(),
    alias: () => require('alias-1/package.json').version,
}
