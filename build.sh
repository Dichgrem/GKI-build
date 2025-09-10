#!/bin/bash
# 设置终端颜色变量（红、绿、黄、白、青）
R="$(printf '\033[1;31m')" # 红色
G="$(printf '\033[1;32m')" # 绿色
Y="$(printf '\033[1;33m')" # 黄色
W="$(printf '\033[1;37m')" # 白色
C="$(printf '\033[1;36m')" # 青色

# 内核源码根目录（当前工作目录）
export KERNEL_DIR=$(pwd)

# LTO（Link Time Optimization）模式，可由外部传入：none / thin / full
export LTO=${LTO}

# 内核 defconfig 文件（默认配置文件）
export KERNEL_DEFCONFIG=config_defconfig

# 编译输出目录，避免污染源码目录
export OUT=out

# 工具链路径（根据环境自行调整）
export CLANG_PATH=/home/dich/kernel/clang-r487747c
export GCC64_PATH=/home/dich/kernel/aarch64-linux-android-4.9
export GCC32_PATH=/home/dich/kernel/arm-linux-androideabi-4.9

# 添加 Clang 工具链到 PATH
export PATH=${CLANG_PATH}/bin:${PATH}

# 指定目标架构
export ARCH=arm64
export SUBARCH=arm64

# 仅使用 Clang 编译所需配置
export LLVM=1
export BUILD_INITRAMFS=1

# 编译线程数（可通过参数覆盖），默认 32 线程
# 使用示例：./build.sh 8
TH_COUNT=32

# 编译所需基础参数
export DEF_ARGS="O=${OUT} \
ARCH=${ARCH} \
CROSS_COMPILE=aarch64-linux-gnu- \
CROSS_COMPILE_COMPAT=arm-linux-gnueabi- \
CC=${CLANG_PATH}/bin/clang \
AR=${CLANG_PATH}/bin/llvm-ar \
NM=${CLANG_PATH}/bin/llvm-nm \
LD=${CLANG_PATH}/bin/ld.lld \
HOSTCC=${CLANG_PATH}/bin/clang \
HOSTCXX=${CLANG_PATH}/bin/clang++ \
OBJCOPY=${CLANG_PATH}/bin/llvm-objcopy \
OBJDUMP=${CLANG_PATH}/bin/llvm-objdump \
READELF=${CLANG_PATH}/bin/llvm-readelf \
OBJSIZE=${CLANG_PATH}/bin/llvm-size \
STRIP=${CLANG_PATH}/bin/llvm-strip \
LLVM_IAS=1 \
LLVM=1"

# 最终编译参数：多线程 + 基础参数
export BUILD_ARGS="-j${TH_COUNT} ${DEF_ARGS}"

echo "=============== Make defconfig ==============="
# 生成 defconfig 配置文件
make ${DEF_ARGS} ${KERNEL_DEFCONFIG}
# 如果 make defconfig 失败则退出
if [[ "0" != "$?" ]]; then
  echo -e ">>> ${R}make defconfig error, 出错!"
  exit 1
fi

# 处理 LTO 配置（仅支持 none/thin/full 三种模式）
if [ "${LTO}" = "none" -o "${LTO}" = "thin" -o "${LTO}" = "full" ]; then
  echo "========================================================"
  echo " Modifying LTO mode to '${LTO}'"

  set -x # 打印执行的命令，便于调试
  if [ "${LTO}" = "none" ]; then
    ${KERNEL_DIR}/scripts/config --file ${OUT}/.config \
      -d LTO_CLANG \
      -e LTO_NONE \
      -d LTO_CLANG_THIN \
      -d LTO_CLANG_FULL \
      -d THINLTO
  elif [ "${LTO}" = "thin" ]; then
    # thin LTO 模式（某些内核可能不支持）
    ${KERNEL_DIR}/scripts/config --file ${OUT}/.config \
      -e LTO_CLANG \
      -d LTO_NONE \
      -e LTO_CLANG_THIN \
      -d LTO_CLANG_FULL \
      -e THINLTO
  elif [ "${LTO}" = "full" ]; then
    # full LTO 模式
    ${KERNEL_DIR}/scripts/config --file ${OUT}/.config \
      -e LTO_CLANG \
      -d LTO_NONE \
      -d LTO_CLANG_THIN \
      -e LTO_CLANG_FULL \
      -d THINLTO
  fi
  set +x # 关闭命令打印
elif [ -n "${LTO}" ]; then
  echo "LTO= 必须是 'none', 'thin' 或 'full' 之一。"
  exit 1
fi

echo "=============== Make Kernel  ==============="
# 开始编译内核
make ${BUILD_ARGS}
if [[ "0" != "$?" ]]; then
  echo ">>> ${R}build kernel error, 构建失败!"
  exit 1
fi
echo ">>> ${G}build Kernel 成功"
exit 0
