import os
import subprocess
import sys
from pathlib import Path

if __name__ == "__main__":
    openapi_ts_bin = os.environ.get("OPENAPI_TS_BIN")
    types_out_dir = os.environ.get("TYPES_OUT_DIR")

    result = subprocess.run(
        [openapi_ts_bin, "--help"],
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        print(f"openapi-typescript failed: {result.stderr}", file=sys.stderr)
        sys.exit(1)

    (Path(types_out_dir) / "help.txt").write_text(result.stdout)
