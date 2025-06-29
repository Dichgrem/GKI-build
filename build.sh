#!/bin/bash

starttime=$(date +'%Y-%m-%d %H:%M:%S')

export ARCH=arm64
export SUBARCH=arm64
export KCONFIG_CONFIG=$PWD/myconfig

# 生成默认 config
make O=out KCONFIG_CONFIG=$KCONFIG_CONFIG olddefconfig

# 编译内核，禁用 frame-larger-than 的错误处理
make -j$(nproc) O=out WERROR=0 \
  KCFLAGS="-Wno-error=frame-larger-than= -O3 -pipe" \
  KCPPFLAGS="-DCONFIG_CC_OPTIMIZE_FOR_PERFORMANCE" \
  HOSTCFLAGS="-O3 -pipe" \
  HOSTCXXFLAGS="-O3 -pipe" \
  NM=~/kernel/toolchains/clang-14/bin/llvm-nm \
  OBJCOPY=~/kernel/toolchains/clang-14/bin/llvm-objcopy \
  LD=~/kernel/toolchains/clang-14/bin/ld.lld \
  CROSS_COMPILE=~/kernel/toolchains/clang-14/bin/aarch64-linux-gnu- \
  CROSS_COMPILE_ARM32=~/kernel/toolchains/gcc-arm-4.9/bin/arm-linux-androideabi- \
  CC=~/kernel/toolchains/clang-14/bin/clang \
  AR=~/kernel/toolchains/clang-14/bin/llvm-ar \
  OBJDUMP=~/kernel/toolchains/clang-14/bin/llvm-objdump \
  STRIP=~/kernel/toolchains/clang-14/bin/llvm-strip \
  2>&1 | tee error.log
