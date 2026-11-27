#!/usr/bin/env python3
"""Package the Android 13 vendor overlays with stable paths and file modes."""

from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

root = Path(__file__).resolve().parents[1]
output = root / ".build"
output.mkdir(exist_ok=True)
for arch in ("x86_64", "arm64"):
    vendor = root / "gnss" / arch
    with ZipFile(output / f"{arch}.zip", "w", compression=ZIP_DEFLATED) as archive:
        for path in sorted(vendor.rglob("*")):
            if path.is_file():
                name = path.relative_to(vendor).as_posix()
                entry = ZipInfo(name)  # The ZIP epoch keeps release digests reproducible.
                entry.create_system = 3
                entry.external_attr = (0o100755 if name.startswith("bin/") else 0o100644) << 16
                archive.writestr(entry, path.read_bytes(), compress_type=ZIP_DEFLATED, compresslevel=9)
