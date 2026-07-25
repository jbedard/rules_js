#!/usr/bin/env bash

set -o pipefail -o errexit -o nounset

# The _lcov_merger step. The lcov report is generated in the test action by
# coverage.js and stashed inside COVERAGE_DIR (which bazel carries to this
# action); here we just move it to the output file bazel expects. Because the
# report is produced in the test action, this step needs no node, sources, or
# runfiles — which also means it can't hit #965 (merger runfiles resolution under
# --experimental_split_coverage_postprocessing). See #2901.
stash="${COVERAGE_DIR:-}/_rules_js_report.dat"
if [ -s "$stash" ]; then
    mv "$stash" "$COVERAGE_OUTPUT_FILE"
fi
# No stash (generation failed or produced nothing): leave the empty
# COVERAGE_OUTPUT_FILE bazel created in the sandbox in place.

{{merge_assertions}}
