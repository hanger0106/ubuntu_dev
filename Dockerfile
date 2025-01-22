# Start with Ubuntu 20.04 LTS.
FROM ubuntu:20.04
ARG WORKDIR="/work"
RUN apt-get update --fix-missing
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils build-essential sudo git libelf-dev bc vim locales libncurses5-dev wget cpio python2 unzip rsync tzdata
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common libssl-dev gawk device-tree-compiler autoconf sbsigntool flex bison curl python3-pip
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y default-jdk
RUN echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN useradd -m user --home-dir $WORKDIR && echo "user:user" | chpasswd && adduser user sudo

# Install gosu
RUN  curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.17/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

# Config TimeZone
RUN TZ=Asia/Taipei \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

# ENTRYPOINT
COPY entrypoint.sh /usr/local/bin/entrypoint.sh 
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD [ "/bin/bash" ]
WORKDIR $WORKDIR
ENV WORKDIR=$WORKDIR

# make /bin/sh symlink to bash instead of dash:
#RUN echo "dash dash/sh boolean false" | debconf-set-selections
#RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

#python3 package
RUN python3 -m pip install cryptography pyyaml filelock

#perl package
RUN apt-get install -y libclone-perl libyaml-perl libmoo-perl liblist-moreutils-perl libdata-compare-perl libmoosex-role-strict-perl libnamespace-autoclean-perl

#python2 package
#RUN apt-get install -y python-yaml 

##make python3 default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python2 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 2 \
    && update-alternatives --set python /usr/bin/python3

#Other project depend package
#lsdk2108
RUN apt-get install -y \
        u-boot-tools device-tree-compiler autoconf automake dh-autoreconf libssl-dev zip \
        openssl curl flex bison bc git gcc vim ethtool wget ftp make makedev tclsh ccache \
        binfmt-support qemu-system-common qemu-user-static debootstrap sudo ncurses-dev  \
        gcc-arm-linux-gnueabihf crossbuild-essential-arm64 gcc-aarch64-linux-gnu file    \
        build-essential gdb u-boot-tools device-tree-compiler python3 python3-dev python3-pip \
        libxml2-dev libsensors4-dev libssl-dev libedit-dev liblzma-dev tree binutils-dev \
        libnuma-dev libpcap-dev libtool mtd-utils libncurses5-dev libelf-dev net-tools   \
        libcunit1-dev pkg-config autotools-dev crossbuild-essential-armhf openssh-server \
        openssh-client crossbuild-essential-armhf qemu-utils kmod g++-aarch64-linux-gnu  \
        cpp-arm-linux-gnueabihf dosfstools ruby iputils-ping cpio rsync libtclap-dev     \
        parted rpm2cpio lsb-release xutils-dev libwayland-bin cmake locales texinfo gawk \
        chrpath diffstat scons libgflags-dev libhdf5-serial-dev python3-numpy python3-wheel \
        python3-h5py elfutils  python3-pyelftools pandoc
RUN chmod 777 /opt
    
#example usage:
#DOCKER_IMAGE=ubuntu_dev
#docker build --tag ${DOCKER_IMAGE} .
#docker build --tag ${DOCKER_IMAGE} https://github.com/hanger0106/ubuntu_dev.git#20.04:.
#docker run -it --rm  -v /tmp:/tmp -e USER_ID=$(id -u) -e USER_NAME="user" ${DOCKER_IMAGE} bash
