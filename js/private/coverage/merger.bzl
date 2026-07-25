"Internal use only"

# Publishes the lcov report generated in the test action (see coverage.js). Pure
# bash: it just moves the stashed report to the output file, so it needs no node.
load("@bazel_lib//lib:windows_utils.bzl", "create_windows_native_launcher_script")

_ATTRS = {
    # Extra bash appended after the report is published; used by tests to assert
    # on the published report.
    "merge_assertions": attr.string(),
    "_launcher_template": attr.label(
        default = Label("//js/private/coverage:coverage.sh.tpl"),
        allow_single_file = True,
    ),
    "_windows_constraint": attr.label(default = "@platforms//os:windows"),
}

def _coverage_merger_impl(ctx):
    is_windows = ctx.target_platform_has_constraint(ctx.attr._windows_constraint[platform_common.ConstraintValueInfo])

    # The '_' avoids collisions with another file matching the label name.
    bash_launcher = ctx.actions.declare_file("{}_/{}".format(ctx.label.name, ctx.label.name))
    ctx.actions.expand_template(
        template = ctx.file._launcher_template,
        output = bash_launcher,
        substitutions = {
            "{{merge_assertions}}": ctx.attr.merge_assertions,
        },
        is_executable = True,
    )

    launcher = create_windows_native_launcher_script(ctx, bash_launcher) if is_windows else bash_launcher

    return DefaultInfo(
        executable = launcher,
        runfiles = ctx.runfiles(),
    )

coverage_merger = rule(
    implementation = _coverage_merger_impl,
    attrs = _ATTRS,
    executable = True,
    toolchains = [
        "@bazel_tools//tools/sh:toolchain_type",
    ],
)
