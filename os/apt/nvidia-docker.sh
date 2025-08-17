#!/bin/bash

# set -euxo pipefail
# export DEBIAN_FRONTEND=noninteractive
# sudo dpkg --set-selections <<< "cloud-init install" || true

# 检查是否安装成功

country=$(curl -s https://ifconfig.icu/country)
if [[ $country == *"China"* ]]; then
    docker_image=registry.cn-shanghai.aliyuncs.com/comfy-ai/mysql-aliyun:latest
    download_url=https://gitee.com/muaimingjun/LinuxCTS/raw/main
    # judge "设置Docker镜点 "
else
    docker_image=nvidia/cuda:12.4.1-base-ubuntu22.04
    download_url=https://raw.githubusercontent.com/muaimingjun/LinuxCTS/main
fi

# Set Gloabal Variables
# Detect OS
#!/bin/bash

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
"Linux")
    # Detect Linux Distro
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID

        # 判断是否是 Debian 大分支
        if [[ "$DISTRO" == "debian" || "$DISTRO" == "ubuntu" || "$DISTRO" == "kali" ]]; then
            echo "Detected Debian family: $DISTRO $VERSION"

            # 判断架构是否是 x86 (32位/64位)
            case "$ARCH" in
                x86_64|i386|i686)
                    echo "Architecture: $ARCH (x86 family)"
                ;;
                *)
                    echo "Unsupported architecture: $ARCH"
                    exit 1
                ;;
            esac
        else
            echo "Not a Debian-based distribution: $DISTRO"
            exit 1
        fi
    else
        echo "Your Linux distribution is not supported."
        exit 1
    fi
    ;;
*)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac


# Detect if an Nvidia GPU is present
NVIDIA_PRESENT=$(lspci | grep -i nvidia || true)

# For testing purposes, this should output NVIDIA's driver version
if [[ ! -z "$NVIDIA_PRESENT" ]]; then
    nvidia-smi
else
    exit 0
fi

install_docker

# Test / Install nvidia-docker
if [[ ! -z "$NVIDIA_PRESENT" ]]; then
    if docker run --rm --gpus all $docker_image nvidia-smi &>/dev/null; then
        echo "nvidia-docker is enabled and working. Exiting script."
    else
        echo "nvidia-docker does not seem to be enabled. Proceeding with installations..."
        # distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
        # nvidia.github.io <- nvidia-docker.geekery.cn
        wget --no-check-certificate ${download_url}/app/nvidia-docker.zip
        apt install -y unzip
        unzip  nvidia-docker.zip
        apt install -y ./nvidia-docker/*.deb
        rm -fr nvidia-docker*
        systemctl restart docker 
        docker run --rm --gpus all $docker_image nvidia-smi
        docker rmi $docker_image
    fi
fi

# sudo apt-mark hold "nvidia*" "libnvidia*"

# # Add docker group and user to group docker
# sudo groupadd docker || true
# sudo usermod -aG docker $USER || true
# newgrp docker || true
# Workaround for NVIDIA Docker Issue
# echo "Applying workaround for NVIDIA Docker issue as per https://github.com/NVIDIA/nvidia-docker/issues/1730"
# Summary of issue and workaround:

mkdir -pv /etc/docker/ || true

echo "你所在的国家是:${country}"
if [[ $country == *"China"* ]]; then
    sudo bash -c 'cat <<EOF > /etc/docker/daemon.json
    {
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "exec-opts": ["native.cgroupdriver=cgroupfs"],
    "registry-mirrors": ["https://docker.ketches.cn/"]
    }
EOF'
    sudo systemctl daemon-reload

    # judge "设置Docker镜点 "
else
    sudo bash -c 'cat <<EOF > /etc/docker/daemon.json
    {
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "exec-opts": ["native.cgroupdriver=cgroupfs"]
    }
EOF'
    echo "当前国家不是China，未执行Docker镜点设置。"
fi

# Restart Docker to apply changes.
sudo systemctl restart docker