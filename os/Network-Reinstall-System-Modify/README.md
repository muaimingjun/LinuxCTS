<div align="center">
  <a href="https://www.cxthhhhh.com/network-reinstall-system-modify">
      <img src="https://raw.githubusercontent.com/MeowLove/Network-Reinstall-System-Modify/master/background/Network-Reinstall-System-Modify_LOGO1.png"  >
  </a>
  <h1 align="center">
    一键网络重装系统 - 魔改版 <br>（Network-Reinstall-System-Modify）
  </h1>
  <h3 align="center">
    通过互联网重新安装Linux和Windows以及常用操作系统。<br> （Reinstall Linux and Windows and Common Operating Systems through the Internet.） <br><br>
  </h3>

  <a href="/LICENSE">
    <img src="https://img.shields.io/badge/license-GPL_3.0-brightgreen.svg" alt="">
  </a>

  <a href="https://github.com/MeowLove/Network-Reinstall-System-Modify/pulls">
    <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="">
  </a>
  
  <a href="https://github.com/MeowLove/Network-Reinstall-System-Modify/issues/new">
    <img src="https://img.shields.io/badge/Issues-welcome-brightgreen.svg">
  </a>
  
  <a href="https://github.com/MeowLove/Network-Reinstall-System-Modify/releases">
    <img src="https://img.shields.io/badge/release-5.3.0-blue.svg?">
  </a>
  
  <a href="https://github.com/MeowLove/Network-Reinstall-System-Modify/releases">
    <img src="https://img.shields.io/github/stars/MeowLove/Network-Reinstall-System-Modify.svg?style=flat-square&label=Stars&logo=github">
  </a>
  
  <a href="https://github.com/MeowLove/Network-Reinstall-System-Modify/">
    <img src="https://img.shields.io/github/forks/MeowLove/Network-Reinstall-System-Modify.svg?style=flat-square&label=Forks&logo=github">
  </a>

  <a href="https://bbs.cxthhhhh.com/">
    <img src="https://img.shields.io/badge/Contact-Forum-orange">
  </a>

  <a href="https://t.me/Technical_Blog">
    <img src="https://img.shields.io/badge/Contact-Telegram-orange">
  </a>
  
</div>
<br>

<div align="center">
  <a href="https://www.cxthhhhh.com/">
    <img src="https://raw.githubusercontent.com/MeowLove/Network-Reinstall-System-Modify/master/background/CXT_Logo.png">
  </a>
  <h3 align="center">
  <hr>
    欢迎加入，让我们一起维护构建【一键网络重装系统】项目。<br>
    <h3>Welcome to Join us, Let's make the "One-click Network Installation System" project better.</h3>
    <br><br>
  </h3>
  <img src="https://raw.githubusercontent.com/MeowLove/Network-Reinstall-System-Modify/master/background/Preview2021.png">
</div>

## LinuxCTS 自托管分支说明

本目录是 [Network-Reinstall-System-Modify](https://github.com/MeowLove/Network-Reinstall-System-Modify) 的本地分支，随 LinuxCTS 主仓库分发：

- 入口：`linux.sh` 菜单 `25 Linux网络重装系统`，脚本通过 `${download_url}/os/Network-Reinstall-System-Modify/` 获取
- 上游 `www.cxthhhhh.com/CXT-Library/...`、`caoxiaotian.com` 与 `odc.cxthhhhh.com` 均已失效，核心脚本 `Core_Install_v5.3.sh` 改为自托管下载，并保留 CN/全球双线路回退
- `odc.cxthhhhh.com` 的 DD 镜像不可用，因此 Windows/OpenWRT/Rocky/Oracle/Alma/Fedora/裸机平台等基于镜像的菜单已暂时隐藏
- 当前保留 Debian 10/11/12/13 与 Ubuntu 20.04/22.04/24.04/26.04 在线重装，推荐 Debian 12 或 Ubuntu 24.04
- Ubuntu 24.04/26.04 使用官方 live-server netboot + autoinstall：安装器会在启动后下载约 3 GB 的 ISO 到内存，建议内存 ≥ 4 GB；官方未提供 ARM64 netboot，故仅支持 x86_64
- 中国大陆环境下，Debian 与 Ubuntu 的软件源、内核/initrd、live-server ISO 全部优先使用 `mirrors.ustc.edu.cn`，中科大缺少时回退官方源；Debian 固件（cdimage 上的 firmware.cpio.gz）中科大未镜像，仍走官方
- Ubuntu 24.04/26.04 安装完成后会自动把目标系统的 apt 源切换到中科大（仅中国大陆环境）
- Ubuntu 22.04 官方没有 netboot：脚本先下载 live-server ISO（约 2 GiB），提取其自带的 casper 内核/initrd 后再以 autoinstall 引导；安装时安装器会再次下载同一 ISO，因此需要磁盘预留约 2 GiB、内存 ≥ 4 GiB（已在虚拟机实测通过）
- 默认账户：`ubuntu`（普通用户）与 `root`，默认密码 `itgpt.top`，SSH 端口 22；安装完成后请立即修改
- 已修复：UEFI 菜单分支条件写法错误导致永远走 Legacy 菜单；补充 Debian 12/13、Ubuntu 22.04/24.04/26.04 版本映射

## 一键网络重装系统 - 魔改版（Network-Reinstall-System-Modify）

### 一键网络重装系统 - 魔改版

[一键网络重装系统 - 魔改版（Network-Reinstall-System-Modify）](https://www.cxthhhhh.com/network-reinstall-system-modify)可以通过互联网重新安装Linux和Windows以及常用操作系统。例如：CentOS、Debian、Ubuntu、Windows 2012R2、Windows Server 2019、Proxmox-VE、OpenWRT等常见系统，还可以通过极客功能[裸机系统部署平台](https://www.cxthhhhh.com/bare-metal_system_deployment_platform)挂载网络【ISO镜像】远程安装任何系统。  
  
[一键网络重装系统 - 魔改版（Network-Reinstall-System-Modify）](https://github.com/MeowLove/Network-Reinstall-System-Modify)，从[MoeClub Vicer](https://moeclub.org/)分支，魔改版增加新功能修复Bug后，由[CXT - Enjoy Life | 自天佑之，吉无不利](https://www.cxthhhhh.com/)提供维护和支持。（更多功能陆续更新中）  

### Network-Reinstall-System-Modify

[Network-Reinstall-System-Modify](https://www.cxthhhhh.com/network-reinstall-system-modify) can reinstall Linux and Windows and common operating systems through the internet. Common systems such as CentOS, Debian, Ubuntu, Windows 2012R2, Windows Server 2019, Proxmox-VE and OpenWRT can also mount the network [ISO image] through the geek function [Bare Metal System Deployment Platform](https://www.cxthhhhh.com/bare-metal_system_deployment_platform).  

[Network-Reinstall-System-Modify](https://github.com/MeowLove/Network-Reinstall-System-Modify), Forked from [MoeClub Vicer](https://moeclub.org/), After the magic revision adds new functions to fix bugs, [CXT - Enjoy Life | 自天佑之，吉无不利](https://www.cxthhhhh.com/) provides maintenance and support. (more Features of the magic version are constantly increasing.)  


## 需求（Realistic Demand）

### 为什么我们需要重新安装一个纯净系统？
<br>
- 服务提供商提供的系统模板可能有一些内置软件，甚至与我们即将安装的软件冲突，导致安装失败。  
- ISO挂载并不是所有服务提供商都提供的服务。有些IPIM/KVM传输速度太慢，安装效率很差。  
- Linux/Windows可能会遇到一些在使用中找不到的莫名其妙的错误。相信你一定深有体会！  
<br>

### Why do we need to reinstall a pure system?
<br>
- The system template provided by the service provider may have some built-in software, even conflicting with the software we are about to install, resulting in the installation failure.  
- ISO mount is not a service provided by all service providers. Some IPIM/KVM transmission speeds are too slow and installation efficiency is poor.  
- Linux/Windows may encounter some inexplicable errors that cannot be found in use. I believe you must have a deep understanding!  
<br>


## 你需要明白（You Need To Understand）
### 官方发布、使用教程、交流社区在哪里？（Where are the Release and Tutorials?）
<br>

1. 官方发布（Release）  
https://www.cxthhhhh.com/network-reinstall-system-modify  

2. 使用教程（Tutorials）  
https://www.cxthhhhh.com/  

3. 社区交流（Forum）  
https://bbs.cxthhhhh.com/  
<br>

## 常见问题（Common Problem）

### 这里和我博客中的教程将涵盖大多数问题的答案。

1. 问：系统安装的默认密码？  
答：通常情况下，默认密码为[itgpt.top]。为了防止暴力破解造成安全隐患，您必须在安装后立即更改默认密码，并做好安全防护！  

2. 问：如何连接和管理我的新系统？  
答：由于硬件配置和网络环境的不同，安装需要10到60分钟，请耐心等待。安装完成后，您可以通过IP:22(Linux SSH)/IP:3389(Windows RDP)进行连接。  

3. 问：如何使用【裸机系统部署平台】安装任何我想要的系统？  
答：这个过程很难用一句话来描述，所以访问我的博客，按照教程来做。https://www.cxthhhhh.com/  

4. 问:为什么Github上存储的项目内容不是全部？  
答：稍有常识的人都知道，Github只能上传小于100MB的文件。但截至2019年01月01日，整个[一键网络重装系统 - 魔改版（Network-Reinstall-System-Modify）](https://www.cxthhhhh.com/network-reinstall-system-modify)项目中的所有文件总计超过50GB（2021年04月16日，超过130GB）。所以我只能上传脚本内容和较小的文件，我搭建的辅助平台将无法上传。但你可以访问[Open Disk CDN](https://odc.cxthhhhh.com/)了解更多。  

5. 问:如何沟通？反馈问题？【支持语言：英语，中文(推荐)】  
答：你可以访问[CXT社区](https://bbs.cxthhhhh.com/)发帖交流和反馈（推荐），或前往我的电报频道、讨论组，进行即时交流和反馈。您也可以提交issues，但这不是即时的。  
<br>

### Here and the tutorials in my blog will cover the answers to most questions.

1. Q：The default password for the system installation?  
A：Usually, Default password is [itgpt.top]. In order to prevent potential safety hazards caused by brute force cracking, you must change the default password immediately after installation and do a good job of safety protection!  

2. Q：How to connect and control my new system？  
A：Due to different hardware configuration and network environment, the installation takes 15 to 60 minutes, please be patient. Once the installation is complete, you can connect via IP: 22 (Linux SSH) / IP: 3389 (Windows RDP).  

3. Q：How to manually install any system using [Bare-metal_System_Deployment_Platform]?  
A：It's hard to describe the process in one sentence, so visit my blog and follow the tutorial. https://www.cxthhhhh.com/  

4. Q：Why isn't the content of the project stored on Github not all?  
A：As we all know, Github can only upload files smaller than 100MB. However, as of January 1, 2019, all files in the entire [Network-Reinstall-System-Modify] (https://www.cxtthhhh.com/Network-Reinstall-System-Modify) project totaled more than 50GB (April 16, 2021, over 136GB). So I can only upload script content and smaller files, and the auxiliary platform I built will not be able to upload. But you can visit [Open Disk CDN](https://odc.cxthhhhh.com/) to learn more.  

5. Q：How to communicate? Feedback question? [Support language English (Recommended), Chinese (中文).]  
A: You can visit [CXT Community Forum](https://bbs.cxthhhhh.com/) to Post Communication and Feedback (recommended), Or goto my Telegram channel and discussion group, and have instant Communication and Feedback. You can also submit issues, but this is not immediate.  
<br>


## 联系我们（Contact-US）
https://www.cxthhhhh.com/contact-us  
<br>
[CXT社区（CXT Community Forum）](https://bbs.cxthhhhh.com/)  
[Telegram Channel：CXT | 自天佑之，吉无不利](https://t.me/CXTHHHHH) and [Telegram Channel：My Share](https://t.me/me_share)  
[Telegram Chat Group：Technical Blog | 技術博客](https://t.me/Technical_Blog) and [Telegram Chat Group：龙宫 | 龙王家族、AI吹水、BB交流](https://t.me/Dragon_Palace)  


## 结语（End Notes）

[CXT - Enjoy Life | 生活、技术、交友、分享 - 自天佑之，吉无不利](https://www.cxthhhhh.com/)  
[One-click Network Installation System](https://www.cxthhhhh.com/network-reinstall-system-modify)  
[一键网络重装系统 - 魔改版（Network-Reinstall-System-Modify）](https://www.cxthhhhh.com/network-reinstall-system-modify)  

Version：V4.1.2  
Date：2021/04/16  

https://www.cxthhhhh.com/