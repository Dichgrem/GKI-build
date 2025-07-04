#!/bin/bash

starttime=$(date +'%Y-%m-%d %H:%M:%S')

export ARCH=arm64
export SUBARCH=arm64
export KCONFIG_CONFIG=$PWD/myconfig

# 设置工具链路径变量
export CLANG_PATH=~/kernel/toolchains/clang-21/bin
export PATH=$CLANG_PATH:$PATH

# 清理构建目录
rm -rf out && mkdir -p out

# 生成默认 config
make O=out KCONFIG_CONFIG=$KCONFIG_CONFIG olddefconfig

# 编译内核
make -j$(nproc) O=out \
  LLVM=1 \
  LTO=thin \
  WERROR=0 \
  KBUILD_NO_WERROR=1 \
  CC=clang \
  AR=llvm-ar \
  LD=ld.lld \
  NM=llvm-nm \
  OBJCOPY=llvm-objcopy \
  OBJDUMP=llvm-objdump \
  STRIP=llvm-strip \
  HOSTCC=clang \
  HOSTCXX=clang++ \
  CROSS_COMPILE= \
  CROSS_COMPILE_ARM32=arm-linux-androideabi- \
  KCFLAGS="--target=aarch64-linux-gnu -O3 -pipe -Wno-error" \
  KCPPFLAGS="-DCONFIG_CC_OPTIMIZE_FOR_PERFORMANCE" \
  HOSTCFLAGS="-O3 -pipe -Wno-error" \
  HOSTCXXFLAGS="-O3 -pipe -Wno-error" \
  2>&1 | tee out/error.log

tail -n 100 out/error.log
ls -la out/arch/arm64/boot/
ls -la out/vmlinux

# 记录结束时间
endtime=$(date +'%Y-%m-%d %H:%M:%S')
echo "Build started at: $starttime"
echo "Build finished at: $endtime"
