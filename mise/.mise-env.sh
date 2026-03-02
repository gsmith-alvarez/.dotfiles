#!/usr/bin/env bash
# Evaluated by mise at shell activation (_.source). Exports are merged into the
# environment only when the relevant binary is present, so this file is safe on
# fresh machines and on macOS where mold does not exist.

# sccache: use as Rust compiler wrapper only after it has been installed
if command -v sccache &>/dev/null; then
    export RUSTC_WRAPPER="sccache"
fi

# mold: Linux-only high-speed linker; skip silently on macOS or if not installed
if command -v mold &>/dev/null; then
    export LDFLAGS="-fuse-ld=mold"
    export RUSTFLAGS="-C link-arg=-fuse-ld=mold"
fi

# Linux-specific Cargo target: set the x86_64 GNU linker only on Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER="clang"
fi
