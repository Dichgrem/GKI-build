import subprocess

# 要检查和安装的软件包列表
packages = [
    "bc",  # 任意精度计算器，内核 Makefile 中常用于数学计算
    "bison",  # 语法分析器生成工具，用于构建内核或其他复杂项目
    "build-essential",  # 包含 gcc/g++/make 等构建 C/C++ 项目的基础工具
    "cpio",  # 用于生成 initramfs 等归档格式
    "curl",  # 命令行工具，用于通过 URL 下载数据（支持 HTTPS）
    "flex",  # 词法分析器生成工具，常与 bison 搭配使用
    "git",  # 用于克隆源码仓库，如 Linux 内核、AOSP 等
    "libncurses-dev",  # 支持终端图形界面，如 `make menuconfig` 内核配置工具
    "libssl-dev",  # OpenSSL 的开发库，用于支持加密通信或模块
    "libelf-dev",  # 用于处理 ELF 格式的文件，如内核镜像、调试信息等
    "lzop",  # 快速压缩工具，用于内核镜像/initramfs 的压缩
    "python3",  # Python 解释器，许多构建/打包脚本使用 Python 编写
    "unzip",  # 用于解压 .zip 格式压缩包，常用于处理资源或模块
    "xz-utils",  # 支持 .xz 格式压缩/解压，常见于内核源码压缩包
    "zstd",  # 高效压缩工具，内核支持的现代压缩算法
    "rsync",  # 高效文件同步工具，常用于备份或同步构建产物
    "ca-certificates",  # 安全证书库，确保 curl/wget 能安全访问 HTTPS 资源
    "wget",  # 类似 curl 的命令行下载工具，适合简单文件下载
    "pahole",  # 用于生成 BTF/DWARF 信息，优化内核结构体布局（eBPF等）
    "dwarves",  # 包含 pahole 工具，用于调试和结构体分析
    "zip",  # 用于创建 .zip 压缩包，如打包 AnyKernel3 项目等
]


def is_installed(pkg_name):
    """检查软件包是否已安装"""
    try:
        subprocess.run(
            ["dpkg", "-s", pkg_name],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        return True
    except subprocess.CalledProcessError:
        return False


def main():
    print("检查并安装缺失的软件包...")
    missing_packages = []

    for pkg in packages:
        if is_installed(pkg):
            print(f"✅ 已安装：{pkg}")
        else:
            print(f"❌ 未安装：{pkg}")
            missing_packages.append(pkg)

    if missing_packages:
        print("\n🔄 正在执行 apt-get update ...")
        try:
            subprocess.run(["sudo", "apt-get", "update"], check=True)
        except subprocess.CalledProcessError:
            print("❌ apt-get update 失败，请检查网络连接或源设置。")
            return

        print("\n⬇️ 开始安装以下缺失的软件包：")
        print(" ".join(missing_packages))
        try:
            subprocess.run(
                ["sudo", "apt-get", "install", "-y"] + missing_packages, check=True
            )
        except subprocess.CalledProcessError:
            print("❌ 安装部分软件包失败，请手动检查。")
    else:
        print("\n✅ 所有软件包已安装，无需操作。")

    print("✅ 所有软件包检查完毕。")


if __name__ == "__main__":
    main()
