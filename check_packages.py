import subprocess

# 要检查和安装的软件包列表
packages = [
    "bc",
    "bison",
    "build-essential",
    "cpio",
    "curl",
    "flex",
    "git",
    "libncurses-dev",
    "libssl-dev",
    "libelf-dev",
    "lzop",
    "python3",
    "unzip",
    "xz-utils",
    "zstd",
    "rsync",
    "ca-certificates",
    "wget",
    "pahole",
    "dwarves",
    "zip",
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
