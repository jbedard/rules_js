#!/bin/bash
# Regression test for https://github.com/aspect-build/rules_js/pull/2778
#
# When the user's config is named next.config.js AND the package.json has
# "type": "module", Next.js CLI finds next.config.js first in CONFIG_FILES
# (next.config.js > next.config.mjs > next.config.ts) and bypasses the
# next.bazel.mjs wrapper. The wrapper's nextjsFixSymlinks() removes
# standalone/node_modules symlinks that point into .aspect_rules_js (the
# Bazel package store). Without the fix, those symlinks remain and the
# standalone server cannot find node_modules at runtime.
set -euo pipefail

SERVER_DIR="$RUNFILES_DIR/_main/esm/server"

if [ ! -d "$SERVER_DIR" ]; then
    echo "ERROR: server directory not found at $SERVER_DIR"
    exit 1
fi

if [ -d "$SERVER_DIR/standalone/node_modules/.aspect_rules_js" ]; then
    echo "FAIL: standalone/node_modules/.aspect_rules_js should not exist"
    echo "The next.bazel.mjs wrapper was not used — Next.js picked up"
    echo "next.config.js directly (CONFIG_FILES checks .js before .mjs),"
    echo "bypassing nextjsFixSymlinks()."
    exit 1
fi

echo "PASS: standalone/node_modules has no .aspect_rules_js symlinks"
