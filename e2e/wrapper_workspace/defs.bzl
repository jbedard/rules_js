load("@aspect_rules_js//js:defs.bzl", "js_run_devserver")

def wrapper_macro(name):
    js_run_devserver(
        name = "%s-bin" % name,
        tool = Label("@wrapper_workspace//:a_bin"),
        # deps = [":node_modules"],
    )
