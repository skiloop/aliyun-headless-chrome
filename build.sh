#!/bin/sh

set -e

BUILD_BASE=$(pwd)
VERSION=${VERSION:-master}


mkdir -p build/chromium

cd build

# install dept_tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

export PATH="/opt/gtk/bin:$PATH:$BUILD_BASE/build/depot_tools"

cd chromium

# fetch chromium source code
# ref: https://www.chromium.org/developers/how-tos/get-the-code/working-with-release-branches
git clone https://chromium.googlesource.com/chromium/src.git

(
  cd src

  # Do a pull because there are usually revisions pushed while we're cloning
  git pull

  # checkout the release tag
  git checkout -b build "$VERSION"
)

# Checkout all the submodules at their branch DEPS revisions
gclient sync --with_branch_heads --jobs 16

cd src

# install dependencies
build/install-build-deps.sh --no-arm --no-prompt --no-syms --no-backwards-compatible --no-nacl 

# specify build flags
mkdir -p out/Headless && \
  echo 'import("//build/args/headless.gn")' > out/Headless/args.gn && \
  echo 'is_debug = false' >> out/Headless/args.gn && \
  echo 'symbol_level = 0' >> out/Headless/args.gn && \
  echo 'is_component_build = false' >> out/Headless/args.gn && \
  echo 'remove_webcore_debug_symbols = true' >> out/Headless/args.gn && \
  echo 'enable_nacl = false' >> out/Headless/args.gn && \
  gn gen out/Headless

# build chromium headless shell
ninja -C out/Headless headless_shell

cp out/Headless/headless_shell "$BUILD_BASE/bin/headless-chromium-unstripped"

cd "$BUILD_BASE"

# strip symbols
strip -o "$BUILD_BASE/bin/headless-chromium" build/chromium/src/out/Headless/headless_shell
