"""Adapt npm repository rules to be called from MODULE.bazel
See https://bazel.build/docs/bzlmod#extension-definition
"""

load("@bazel_features//:features.bzl", "bazel_features")
load("//npm:repositories.bzl", "npm_import", "pnpm_repository", _LATEST_PNPM_VERSION = "LATEST_PNPM_VERSION")
load("//npm/private:npm_translate_lock.bzl", "npm_translate_lock_lib", "npm_translate_lock_rule_extension")
load("//npm/private:npm_import.bzl", "npm_import_lib", "npm_import_links_lib")

LATEST_PNPM_VERSION = _LATEST_PNPM_VERSION

def _npm_extension_impl(module_ctx):
    for mod in module_ctx.modules:
        for attr in mod.tags.npm_translate_lock:
            _npm_translate_lock_bzlmod(module_ctx, attr)

        for i in mod.tags.npm_import:
            _npm_import_bzlmod(i)

    if bazel_features.external_deps.extension_metadata_has_reproducible:
        return module_ctx.extension_metadata(
            reproducible = True,
        )
    return module_ctx.extension_metadata()

def _npm_translate_lock_bzlmod(module_ctx, attr):
    module_ctx.report_progress("npm_translate_lock %s" % attr.name)

    npm_translate_lock_rule_extension(
        module_ctx,
        attr.name,
        attr,
        npm_import,
    )

def _npm_import_bzlmod(i):
    npm_import(
        name = i.name,
        bins = i.bins,
        commit = i.commit,
        custom_postinstall = i.custom_postinstall,
        deps = i.deps,
        dev = i.dev,
        extra_build_content = i.extra_build_content,
        integrity = i.integrity,
        lifecycle_hooks = i.lifecycle_hooks,
        lifecycle_hooks_env = i.lifecycle_hooks_env,
        lifecycle_hooks_execution_requirements = i.lifecycle_hooks_execution_requirements,
        lifecycle_hooks_use_default_shell_env = i.lifecycle_hooks_use_default_shell_env,
        link_packages = i.link_packages,
        link_workspace = i.link_workspace,
        npm_auth = i.npm_auth,
        npm_auth_basic = i.npm_auth_basic,
        npm_auth_username = i.npm_auth_username,
        npm_auth_password = i.npm_auth_password,
        package = i.package,
        package_visibility = i.package_visibility,
        patch_args = i.patch_args,
        patches = i.patches,
        replace_package = i.replace_package,
        root_package = i.root_package,
        transitive_closure = i.transitive_closure,
        url = i.url,
        version = i.version,
    )

def _npm_translate_lock_attrs():
    attrs = dict(**npm_translate_lock_lib.attrs)

    # Add macro attrs that aren't in the rule attrs.
    attrs["name"] = attr.string()
    attrs["lifecycle_hooks_exclude"] = attr.string_list(default = [])
    attrs["lifecycle_hooks_no_sandbox"] = attr.bool(default = True)
    attrs["run_lifecycle_hooks"] = attr.bool(default = True)

    # Args defaulted differently by the macro
    attrs["npm_package_target_name"] = attr.string(default = "{dirname}")

    attrs.pop("repositories_bzl_filename")

    return attrs

def _npm_import_attrs():
    attrs = dict(**npm_import_lib.attrs)
    attrs.update(**npm_import_links_lib.attrs)

    # Add macro attrs that aren't in the rule attrs.
    attrs["name"] = attr.string()
    attrs["lifecycle_hooks_no_sandbox"] = attr.bool(default = False)
    attrs["run_lifecycle_hooks"] = attr.bool(default = False)

    # Args defaulted differently by the macro
    attrs["lifecycle_hooks_execution_requirements"] = attr.string_list(default = ["no-sandbox"])
    attrs["patch_args"] = attr.string_list(default = ["-p0"])
    attrs["package_visibility"] = attr.string_list(default = ["//visibility:public"])

    return attrs

npm = module_extension(
    implementation = _npm_extension_impl,
    tag_classes = {
        "npm_translate_lock": tag_class(attrs = _npm_translate_lock_attrs()),
        "npm_import": tag_class(attrs = _npm_import_attrs()),
    },
)

def _pnpm_extension_impl(module_ctx):
    for mod in module_ctx.modules:
        for attr in mod.tags.pnpm:
            pnpm_repository(
                name = attr.name,
                pnpm_version = (
                    (attr.pnpm_version, attr.pnpm_version_integrity) if attr.pnpm_version_integrity else attr.pnpm_version
                ),
            )

pnpm = module_extension(
    implementation = _pnpm_extension_impl,
    tag_classes = {
        "pnpm": tag_class(
            attrs = {
                "name": attr.string(),
                "pnpm_version": attr.string(default = LATEST_PNPM_VERSION),
                "pnpm_version_integrity": attr.string(),
            },
        ),
    },
)
