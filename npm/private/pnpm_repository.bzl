"""Repository rules to import pnpm.
"""

load(":npm_import.bzl", _npm_import = "npm_import")
load(":versions.bzl", "PNPM_VERSIONS")

LATEST_PNPM_VERSION = PNPM_VERSIONS.keys()[-1]

# Default to the latest pnpm v8 since pnpm v9 has breaking changes in the lockfile that have not yet been
# tested at scale to ensure all corner cases are covered in the wild.
DEFAULT_PNPM_VERSION = [v for v in PNPM_VERSIONS.keys() if v.startswith("8")][-1]

def pnpm_repository(name, pnpm_version = DEFAULT_PNPM_VERSION):
    """Import https://npmjs.com/package/pnpm and provide a js_binary to run the tool.

    Useful as a way to run exactly the same pnpm as Bazel does, for example with:
    bazel run -- @pnpm//:pnpm --dir $PWD

    Args:
        name: name of the resulting external repository
        pnpm_version: version of pnpm, see https://www.npmjs.com/package/pnpm?activeTab=versions

            May also be a tuple of (version, integrity) where the integrity value may be fetched like:
            `curl --silent https://registry.npmjs.org/pnpm | jq '.versions["8.6.11"].dist.integrity'`
    """

    if not native.existing_rule(name):
        if type(pnpm_version) == "tuple":
            integrity = pnpm_version[1]
            pnpm_version = pnpm_version[0]
        elif type(pnpm_version) == "string":
            integrity = PNPM_VERSIONS[pnpm_version]
        else:
            fail("pnpm_version should be string or tuple, got " + type(pnpm_version))

        _npm_import(
            name = name,
            integrity = integrity,
            package = "pnpm",
            root_package = "",
            version = pnpm_version,
            extra_build_content = "\n".join([
                """load("@aspect_rules_js//js:defs.bzl", "js_binary")""",
                """js_binary(name = "pnpm", data = glob(["package/**"]), entry_point = "package/dist/pnpm.cjs", visibility = ["//visibility:public"])""",
            ]),
            extract_full_archive = True,
        )
