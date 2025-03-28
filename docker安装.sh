#!/bin/bash

# 检查系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    # 尝试获取更详细的版本号
    if [[ $NAME == *"CentOS"* ]]; then
        VER=$(cat /etc/redhat-release | sed 's/.*release //;s/ .*//')
    elif [[ $NAME == *"Armbian"* ]]; then
        OS="Armbian"
        VER=$VERSION_ID
    else
        VER=$VERSION_ID
    fi
elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/redhat-release ]; then
    OS="Red Hat/CentOS"
    VER=$(cat /etc/redhat-release | sed 's/.*release //;s/ .*//')
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

# 获取 CPU 信息
if [[ $OS == *"CentOS"* || $OS == *"Red Hat"* ]]; then
    CPU_INFO=$(lscpu)
else
    CPU_INFO=$(lscpu) # 后续可根据不同系统修改这里的指令
fi

# 输出识别到的系统信息、具体版本号和 CPU 信息
echo "识别到的系统: $OS"
echo "系统具体版本号: $VER"
echo "CPU 信息:"
echo "$CPU_INFO"

# 获取 CPU 架构信息
ARCH=$(uname -m)

# 输出开发者联系方式
GREEN='\033[0;32m'
NC='\033[0m' # 重置颜色
echo -e "${GREEN}开发者联系方式: example@example.com${NC}"

# 判断 Docker 是否已经安装
docker_installed=false
if command -v docker &> /dev/null; then
    echo "Docker 已经安装，无需再次安装。"
    docker_installed=true
fi

# 提示用户输入 y 以承担风险
read -p "继续安装 Docker 可能会有一定风险，确认要继续吗？输入 y 继续，其他任意键退出: " RESPONSE
if [ "$RESPONSE" != "y" ]; then
    echo "安装已取消。"
    exit 0
fi

# 根据不同系统执行不同安装步骤
if [ "$docker_installed" = false ]; then
    if [[ $OS == *"Ubuntu"* || $OS == *"Debian"* || $OS == *"Armbian"* ]]; then
        # Ubuntu、Debian 或 Armbian 系统
        # 更新包索引
        sudo apt-get update
        # 安装必要的包
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
        # 添加 Docker 的官方 GPG 密钥
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        # 添加 Docker 稳定版仓库
        if [[ $ARCH == "arm64" || $ARCH == "aarch64" ]]; then
            if [[ $OS == *"Ubuntu"* ]]; then
                sudo add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
            elif [[ $OS == *"Debian"* ]]; then
                CODENAME=$(lsb_release -cs)
                sudo sh -c "echo 'deb [arch=arm64] https://download.docker.com/linux/debian $CODENAME stable' > /etc/apt/sources.list.d/docker.list"
            elif [[ $OS == *"Armbian"* ]]; then
                CODENAME=$(lsb_release -cs 2>/dev/null || echo "unknown")
                sudo sh -c "echo 'deb [arch=arm64] https://download.docker.com/linux/debian $CODENAME stable' > /etc/apt/sources.list.d/docker.list"
            fi
        else
            if [[ $OS == *"Ubuntu"* ]]; then
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
            elif [[ $OS == *"Debian"* ]]; then
                CODENAME=$(lsb_release -cs)
                sudo sh -c "echo 'deb [arch=amd64] https://download.docker.com/linux/debian $CODENAME stable' > /etc/apt/sources.list.d/docker.list"
            elif [[ $OS == *"Armbian"* ]]; then
                CODENAME=$(lsb_release -cs 2>/dev/null || echo "unknown")
                sudo sh -c "echo 'deb [arch=amd64] https://download.docker.com/linux/debian $CODENAME stable' > /etc/apt/sources.list.d/docker.list"
            fi
        fi
        # 更新包索引
        sudo apt-get update
        # 安装 Docker CE
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    elif [[ $OS == *"CentOS"* || $OS == *"Red Hat"* ]]; then
        # CentOS 或 Red Hat 系统
        # 安装必要的依赖包
        sudo yum install -y yum-utils device-mapper-persistent-data lvm2
        # 设置 Docker 镜像仓库
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        # 替换为阿里云镜像源
        if [[ $ARCH == "arm64" || $ARCH == "aarch64" ]]; then
            sudo sed -i 's+https://download.docker.com+https://mirrors.aliyun.com/docker-ce+; s/x86_64/arm64/' /etc/yum.repos.d/docker-ce.repo
        else
            sudo sed -i 's+https://download.docker.com+https://mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
        fi
        # 清除 Yum 缓存并重新生成
        sudo yum clean all
        sudo yum makecache
        # 安装 Docker Engine、CLI 和 containerd
        sudo yum install -y docker-ce docker-ce-cli containerd.io
    else
        echo "不支持的系统: $OS $VER"
        exit 1
    fi

    # 启动 Docker 服务
    sudo systemctl start docker

    # 设置 Docker 开机自启
    sudo systemctl enable docker
    
    # 查看 Docker版本
    sudo docker -v 
fi