#!/bin/sh
set -e

# install
cd /root/rust-mir-checker
# shellcheck disable=SC1091
. "$HOME/.cargo/env"
export LIBCLANG_PATH=/opt/clang+llvm-15.0.6-x86_64-linux-gnu-ubuntu-18.04/lib/libclang.so
export PATH=/opt/clang+llvm-15.0.6-x86_64-linux-gnu-ubuntu-18.04/bin:$PATH
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"$HOME"/.rustup/toolchains/nightly-2020-12-29-x86_64-unknown-linux-gnu/lib
export RUSTFLAGS="-Clink-args=-fuse-ld=lld"
cargo build --verbose

# exec commands
if [ -n "$*" ]; then
    sh -c "$*"
fi

# keep the docker container running
# https://github.com/docker/compose/issues/1926#issuecomment-422351028
if [ "${KEEPALIVE}" -eq 1 ]; then
    trap : TERM INT
    tail -f /dev/null & wait
    # sleep infinity & wait
fi