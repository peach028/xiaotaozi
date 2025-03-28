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
    ver = $（cat/etc/redhat-release | sed 's/.*版本//; s/。*//'）
别的
    OS = $（UNAME -S）
    VER = $（UNAME -R）
fi

＃获取cpu信息
如果[[ $ os == * “ centos” * || $ os == * “红色帽子” *]];然后
    cpu_info = $（lscpu）
别的
    cpu_info = $（lscpu）＃后续可根据不同系统修改这里的指令
fi

＃输出识别到的系统信息、具体版本号和 cpu信息
回声“识别到的系统：$ os ”
回声“系统具体版本号：$ ver ”
Echo “ CPU信息：”
Echo “ $ cpu_info ”

＃CPU架构信息
Arch = $（UNAME -M）

＃输出开发者联系方式
绿色= '\ 033 [0; 32m'
nc = '\ 033 [0m'  ＃重置颜色
echo -e  “ $ {green}开发者联系方式：桃子QQ：14444316761 $ {NC} ”

＃docker是否已经安装
docker_installed = false
如果命令-v docker＆> /dev /null;然后
    Echo “ Docker已经安装，无需再次安装。”
    docker_installed = true
fi

＃提示用户输入Y以承担风险
读-p  “ docker可能会有一定风险
如果[ “ $ wendesp ”！= “ y” ];然后
    回声“安装已取消。”
    出口 0
fi

＃根据不同系统执行不同安装步骤
如果[ “ $ docker_installed ” = false ];然后
    如果[[ $ os == * “ ubuntu” * || $ OS == * “ Debian” * || $ OS == * “ Armbian” *]];然后
        ＃ubuntu，debian或armbian系统
        ＃更新包索引
        sudo apt-get更新
        ＃安装必要的包
        sudo apt-get install -y apt-transport-https ca-cectifates curl gnupg-gnupg-gnupg-afts offact-properties-common
        ＃docker的官方gpg密钥
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        # 添加 Docker 稳定版仓库
        if [[ $ARCH == "arm64" || $ARCH == "aarch64" ]]; then
            if [[ $OS == *"Ubuntu"* ]]; then
                sudo add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
            elif [[ $OS == *"Debian"* ]]; then
                CODENAME=$(lsb_release -cs)
                sudo sh -c  “ echo deb [arch = arm64] https://download.docker.com/linux/debian $ codename stable stable'> /etc/apt/sources.list.list.d/docker.list.list”
            elif [[ $ os == * “ armbian” *]];然后
                codename = $（lsb_release -cs 2>/dev/null || echo “ unknown”）
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
