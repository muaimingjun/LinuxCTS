#!/bin/bash

## License: GPL
## The CXT Version of one-click network reinstallation system Magic revision.
## It can reinstall CentOS, Rocky, Debian, Ubuntu, Oracle and other General Operating Systems (continuously added) via the network in one click.
## It can reinstall Windwos 2022, 2019, 2016, 2012R2, Windows 10, 11 and other Windows systems (continuously added) via the network in one click.
## Support GRUB or GRUB2 for installing a clean minimal system.
## Technical support is provided by the CXT (CXTHHHHH.com). (based on the original Version of Vicer)

## Magic Modify Version author:
## Default root password: cxthhhhh.com
## WebSite: https://cxthhhhh.com
## Written By CXT (CXTHHHHH.com)

## Original Version author:
## Blog: https://moeclub.org
## Written By MoeClub.org (Vicer)

CXTaddLine="$1"
CXTaddVER=""
CXTisUEFI=""
CXTmyipapi=""
CXTisCN="No"
# 自托管地址：脚本随 LinuxCTS 主仓库分发（上游 cxthhhhh.com / caoxiaotian.com 已失效）
CXTrepoCN="https://linuxcts.itgpt.top/os/Network-Reinstall-System-Modify"
CXTrepoGlobal="https://raw.githubusercontent.com/muaimingjun/LinuxCTS/main/os/Network-Reinstall-System-Modify"
CXTcoreFile="CoreShell/Core_Install_v5.3.sh"

if [[ $EUID -ne 0 ]]; then
    clear
    echo "错误: 重装脚本必须使用root权限执行" 1>&2
    echo "Error: This Reinstall script must be run as root!" 1>&2
    exit 1
fi

echo -e "\n\n\n"
clear
echo -e "\n"
echo "---------------------------------------------------------------------------------------------------------------------"
echo -e "\033[33m 一键网络重装系统 - 魔改版 版本：V5.3.0 更新：2022年07月18日 \033[0m"
echo -e "\033[33m Network-Reinstall-System-Modify Tools V5.3.0 2022/07/18 \033[0m"
echo "---------------------------------------------------------------------------------------------------------------------"
echo -e "\033[33m 一键网络重装系统 - 魔改版（适用于Linux / Windows） \033[0m"
echo -e "\033[33m 系统需求: 任何带有GRUB或GRUB2的Linux操作系统即可运行, 当前推荐安装的系统为： Debian12/Ubuntu24.04 \033[0m"
echo -e "\n"
echo -e "\033[33m [Magic Modify] Reinstall the system (any Windows / Linux) requires only network and one click \033[0m"
echo -e "\033[33m System requirements: Any Linux system with GRUB or GRUB2, recommended Debian12/Ubuntu24.04 \033[0m"
echo -e "\n"
echo -e "\033[33m 官方更新地址（Official update address）：CXT - Enjoy Life | 生活、技术、交友、分享 \033[0m"
echo -e "\033[33m https://cxthhhhh.com/Network-Reinstall-System-Modify \033[0m"
echo "---------------------------------------------------------------------------------------------------------------------"
echo " 默认密码: cxthhhhh.com"
echo " Default password: cxthhhhh.com"
echo "---------------------------------------------------------------------------------------------------------------------"
echo -e "\n"
sleep 6s

echo "---------------------------------------------------------------------------------------------------------------------"
echo " 对当前系统环境进行处理. . ."
echo " Pre-environment preparation. . ."
echo "---------------------------------------------------------------------------------------------------------------------"
echo -e "\n"
sleep 2s

if [ -f "/usr/bin/apt-get" ];then
	isDebian=`cat /etc/issue|grep Debian`
	if [ "$isDebian" != "" ];then
		echo '当前系统 是 Debian'
		echo 'Current system is Debian'
		apt-get install -y xz-utils openssl gawk file wget curl
		apt install -y xz-utils openssl gawk file wget curl
		sleep 3s
	else
		echo '当前系统 是 Ubuntu'
		echo 'Current system is Ubuntu'
		apt-get install -y xz-utils openssl gawk file wget curl
		apt install -y xz-utils openssl gawk file wget curl
		sleep 3s
	fi
else
    echo '当前系统 是 CentOS/Rocky/Oracle/RHEL'
    echo 'Current system is CentOS/Rocky/Oracle/RHEL'
    yum install -y xz openssl gawk file wget curl
    dnf install -y xz openssl gawk file wget curl
    sleep 3s
fi

echo "---------------------------------------------------------------------------------------------------------------------"
echo " 对当前系统环境进行处理. . .  【OK】"
echo " Pre-environment preparation. . .  【OK】"
echo -e "\n"
echo " 检测系统信息. . . "
echo " Detection system information. . . "
echo "---------------------------------------------------------------------------------------------------------------------"
echo -e "\n"
sleep 1s

CXTDTYPE=`fdisk -l | grep -o gpt | head -1`
if [[ "$CXTDTYPE" == "gpt" || "$CXTDTYPE" == "GPT" ]];then
echo "UEFI..."
CXTisUEFI="是(True)"
else
echo "Legacy..."
CXTisUEFI="否(False)"
fi

case `uname -m` in aarch64|arm64) CXTaddVER="arm64";; x86|i386|i686) CXTaddVER="i386";; x86_64|amd64) CXTaddVER="amd64";; *) CXTaddVER="";; esac

CXTmyipapi=$(wget --no-check-certificate -qO- https://api.myip.com | grep "\"country\":\"China\"")
if [[ "$CXTmyipapi" != "" ]];then
  CXTisCN="Yes"
fi
export CXTisCN

if [ "$CXTisCN" != "Yes" ];then
    echo "Core Download（Global）..."
    CXTbaseURL="$CXTrepoGlobal"
    CentOSMirrors=""
    CentOSVaultMirrors=""
    DebianMirrors=""
    UbuntuMirrors=""
else
    echo "Core Download（CN）..."
    CXTbaseURL="$CXTrepoCN"
    CXTrandom=$RANDOM
    if [ $[CXTrandom%2] == "0" ];then
        echo "本次随机使用阿里源"
        CentOSMirrors="--mirror http://mirrors.aliyun.com/centos/"
        CentOSVaultMirrors="--mirror http://mirrors.aliyun.com/centos-vault/"
        DebianMirrors="--mirror http://mirrors.aliyun.com/debian/"
        UbuntuMirrors="--mirror http://mirrors.aliyun.com/ubuntu/"
    else
        echo "本次随机使用清华源"
        CentOSMirrors="--mirror http://mirrors.tuna.tsinghua.edu.cn/centos/"
        CentOSVaultMirrors="--mirror http://mirrors.tuna.tsinghua.edu.cn/centos-vault/"
        DebianMirrors="--mirror http://mirrors.tuna.tsinghua.edu.cn/debian/"
        UbuntuMirrors="--mirror http://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
    fi
    # Ubuntu 统一优先使用中科大源
    UbuntuMirrors="--mirror http://mirrors.ustc.edu.cn/ubuntu/"
fi

# 下载安装核心脚本：优先当前线路，其次备用线路，最后回退上游（上游目前 404，仅作保留）
CXTcoreDownloaded="No"
CXTtriedURL=""
for CXTcoreURL in "$CXTbaseURL/$CXTcoreFile" "$CXTrepoCN/$CXTcoreFile" "$CXTrepoGlobal/$CXTcoreFile"; do
    [ "$CXTcoreURL" == "$CXTtriedURL" ] && continue
    CXTtriedURL="$CXTcoreURL"
    echo "Core Source: $CXTcoreURL"
    wget --no-check-certificate -qO ~/Core_Install.sh "$CXTcoreURL" && [ -s ~/Core_Install.sh ] && CXTcoreDownloaded="Yes" && break
done
if [ "$CXTcoreDownloaded" != "Yes" ]; then
    echo -e "\033[31m错误：无法下载安装核心脚本，请检查网络或下载地址。\033[0m"
    echo -e "\033[31mError: Failed to download Core_Install.sh.\033[0m"
    exit 1
fi
chmod a+x ~/Core_Install.sh

echo "---------------------------------------------------------------------------------------------------------------------"
echo " 系统信息如下. . .  【OK】"
echo " System information is as follows. . .  【OK】"
echo -e "\n"
echo "你的系统架构是：$CXTaddVER"
echo "Your system firmware architecture is: $CXTaddVER"
echo -e "\n"
echo "你的设备启动类型是UEFI：$CXTisUEFI"
echo "Your device Startup type is UEFI: $CXTisUEFI"
echo -e "\n"
echo "使用大陆加速：$CXTisCN"
echo "Accelerating Chinese mainland with CDN: $CXTisCN"
echo -e "\n"
echo " 启动系统安装. . . "
echo " Start system installation. . . "
echo "---------------------------------------------------------------------------------------------------------------------"
echo -e "\n"
sleep 3s

if [ $CXTaddVER == "arm64" ];then
echo "打印ARM64菜单"
echo -e "\n"
clear
echo -e "\n\n\n"
clear
echo -e "\n"
echo "                                                           "
echo "================================================================"
echo "=                                                              ="
echo "=           一键网络重装系统 - 魔改版（ARM64安装）                ="
echo "=        Network-Reinstall-System-Modify (Graphical Install)   ="
echo "=                                                              ="
echo "=             V5.3.0             https://www.cxthhhhh.com      ="
echo "=                                                              ="
echo "================================================================"
echo "                                                                "
echo "您想安装哪个系统(Which System want to Install): "
echo "                                                                "
  # 镜像类菜单（AlmaLinux/CentOS 7/Fedora/Oracle/Rocky/裸机平台）暂时隐藏：上游 odc.cxthhhhh.com 镜像源已失效
  # Ubuntu 24.04/26.04 官方未提供 ARM64 netboot，暂不提供
  echo "   1) Debian 12(ARM64)【Recommend】"
  echo "   2) Debian 13(ARM64)"
  echo "   3) Debian 11(ARM64)"
  echo "   4) Debian 10(ARM64)"
  echo "   5) Ubuntu 20(ARM64)"
  echo "   0) Exit"
  echo -ne "\n请选择(Your option): "
  echo "                                                                "
  read N
  case $N in
    1) echo -e "\nInstall...Debian 12(ARM64)\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -d 12 -a -v arm64 $DebianMirrors $CXTaddLine ;;
    2) echo -e "\nInstall...Debian 13(ARM64)\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -d 13 -a -v arm64 $DebianMirrors $CXTaddLine ;;
    3) echo -e "\nInstall...Debian 11(ARM64)\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -d 11 -a -v arm64 $DebianMirrors $CXTaddLine ;;
    4) echo -e "\nInstall...Debian 10(ARM64)\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -d 10 -a -v arm64 $DebianMirrors $CXTaddLine ;;
    5) echo -e "\nInstall...Ubuntu 20(ARM64)\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -u 20.04 -a -v arm64 $UbuntuMirrors $CXTaddLine ;;
    0) exit 0;;
    *) echo "Wrong input!"; exit 1;;
    esac
elif [[ "$CXTisUEFI" == "是(True)" ]] && [[ "$CXTaddVER" != "arm64" ]];then
echo "打印UEFI菜单"
echo -e "\n"
clear
echo -e "\n\n\n"
clear
echo -e "\n"
echo "                                                           "
echo "================================================================"
echo "=                                                              ="
echo "=           一键网络重装系统 - 魔改版（UEFI安装）                 ="
echo "=        Network-Reinstall-System-Modify (Graphical Install)   ="
echo "=                                                              ="
echo "=             V5.3.0             https://www.cxthhhhh.com      ="
echo "=                                                              ="
echo "================================================================"
echo "                                                                "
echo "您想安装哪个系统(Which System want to Install): "
echo "                                                                "
  # 镜像类菜单（CentOS/OpenWRT/Oracle/Rocky/Windows/裸机平台）暂时隐藏：上游 odc.cxthhhhh.com 镜像源已失效
  echo "   1) Debian 12(UEFI)【Recommend】"
  echo "   2) Debian 13(UEFI)"
  echo "   3) Debian 11(UEFI)"
  echo "   4) Debian 10(UEFI)"
  echo "   5) Ubuntu 24.04(UEFI)【Recommend】"
  echo "   6) Ubuntu 26.04(UEFI)"
  echo "   7) Ubuntu 22.04(UEFI)"
  echo "   8) Ubuntu 20.04(UEFI)"
  echo "   0) Exit"
  echo -ne "\n请选择(Your option): "
  echo "                                                                "
  read N
  case $N in
    1) echo -e "\nInstall...Debian 12(UEFI)\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -d 12 -a -v 64 -firmware $DebianMirrors $CXTaddLine ;;
    2) echo -e "\nInstall...Debian 13(UEFI)\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -d 13 -a -v 64 -firmware $DebianMirrors $CXTaddLine ;;
    3) echo -e "\nInstall...Debian 11(UEFI)\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -d 11 -a -v 64 -firmware $DebianMirrors $CXTaddLine ;;
    4) echo -e "\nInstall...Debian 10(UEFI)\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -d 10 -a -v 64 -firmware $DebianMirrors $CXTaddLine ;;
    5) echo -e "\nInstall...Ubuntu 24.04(UEFI)\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -u 24.04 -a -v 64 $UbuntuMirrors $CXTaddLine ;;
    6) echo -e "\nInstall...Ubuntu 26.04(UEFI)\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -u 26.04 -a -v 64 $UbuntuMirrors $CXTaddLine ;;
    7) echo -e "\nInstall...Ubuntu 22.04(UEFI)\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -u 22.04 -a -v 64 -firmware $UbuntuMirrors $CXTaddLine ;;
    8) echo -e "\nInstall...Ubuntu 20.04(UEFI)\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -u 20.04 -a -v 64 -firmware $UbuntuMirrors $CXTaddLine ;;
    0) exit 0;;
    *) echo "Wrong input!"; exit 1;;
    esac
else
echo "打印标准菜单"
echo -e "\n"
clear
echo -e "\n\n\n"
clear
echo -e "\n"
echo "                                                           "
echo "================================================================"
echo "=                                                              ="
echo "=           一键网络重装系统 - 魔改版（BIOS Legacy安装）          ="
echo "=        Network-Reinstall-System-Modify (Graphical Install)   ="
echo "=                                                              ="
echo "=             V5.3.0             https://www.cxthhhhh.com      ="
echo "=                                                              ="
echo "================================================================"
echo "                                                                "
echo "您想安装哪个系统(Which System want to Install): "
echo "                                                                "
  # 镜像类菜单（CentOS/OpenWRT/Oracle/Rocky/Windows/裸机平台）暂时隐藏：上游 odc.cxthhhhh.com 镜像源已失效
  echo "   1) Debian 12【Recommend】"
  echo "   2) Debian 13"
  echo "   3) Debian 11"
  echo "   4) Debian 10"
  echo "   5) Ubuntu 24.04【Recommend】"
  echo "   6) Ubuntu 26.04"
  echo "   7) Ubuntu 22.04"
  echo "   8) Ubuntu 20.04"
  echo "   0) Exit"
  echo -ne "\n请选择(Your option): "
  echo "                                                                "
  read N
  case $N in
    1) echo -e "\nInstall...Debian 12\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -d 12 -a -v 64 $DebianMirrors $CXTaddLine ;;
    2) echo -e "\nInstall...Debian 13\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -d 13 -a -v 64 $DebianMirrors $CXTaddLine ;;
    3) echo -e "\nInstall...Debian 11\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -d 11 -a -v 64 $DebianMirrors $CXTaddLine ;;
    4) echo -e "\nInstall...Debian 10\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -d 10 -a -v 64 $DebianMirrors $CXTaddLine ;;
    5) echo -e "\nInstall...Ubuntu 24.04\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -u 24.04 -a -v 64 $UbuntuMirrors $CXTaddLine ;;
    6) echo -e "\nInstall...Ubuntu 26.04\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -u 26.04 -a -v 64 $UbuntuMirrors $CXTaddLine ;;
    7) echo -e "\nInstall...Ubuntu 22.04\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -u 22.04 -a -v 64 $UbuntuMirrors $CXTaddLine ;;
    8) echo -e "\nInstall...Ubuntu 20.04\n"; read -s -n1 -p "任意键继续(Press any key to continue...)" ; bash ~/Core_Install.sh -u 20.04 -a -v 64 $UbuntuMirrors $CXTaddLine ;;
    0) exit 0;;
    *) echo "Wrong input!"; exit 1;;
    esac
fi

echo "---------------------------------------------------------------------------------------------------------------------"
echo -e "\033[35m 启动 安装 \033[0m"
echo -e "\033[32m Start Installation \033[0m"
echo "---------------------------------------------------------------------------------------------------------------------"
echo -e "\n"