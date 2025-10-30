#!/bin/bash
set -euo pipefail

R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
C="$(printf '\033[1;36m')"
W="$(printf '\033[0m')"

ORIG_ZIP="anykernel3-sukisu-susfs-nokpm-6.1.130.zip"
NEW_ZIP="anykernel3-sukisu-susfs-nokpm-6.1.130-new.zip"
WORK_DIR="ak3_work"
NEW_IMAGE="Image"

echo -e "${C}🧹 清理旧文件...${W}"
rm -rf "$WORK_DIR" "$NEW_ZIP"
mkdir -p "$WORK_DIR"

cd "$WORK_DIR"
echo -e "${C}📦 解压原始刷机包...${W}"
unzip -q "../$ORIG_ZIP" || { echo -e "${R}❌ 解压失败！${W}"; exit 1; }

FILE_COUNT=$(find . -type f | wc -l)
(( FILE_COUNT > 10 )) || { echo -e "${R}❌ 文件数量异常: $FILE_COUNT${W}"; exit 1; }
echo -e "${G}✅ 解压成功，共 $FILE_COUNT 个文件。${W}"

echo -e "${C}🪣 备份原始 Image 文件...${W}"
cp -f Image ../Image.old.backup

echo -e "${C}🔁 替换新的 Image 文件...${W}"
cp -f ../$NEW_IMAGE ./Image
chmod 755 Image

echo -e "${C}📦 重新打包刷机包...${W}"
zip -r -q "../$NEW_ZIP" . -x "*/.*"

cd ..
echo -e "${G}✅ 操作完成！新刷机包: $NEW_ZIP${W}"