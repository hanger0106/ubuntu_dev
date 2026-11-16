# Start with Ubuntu 20.04 LTS.
# ---------------------------------------------------------------------------
# NOTE (2026-11-16): this is the upstream Dockerfile from
#   https://github.com/hanger0106/ubuntu_dev (branch 20.04)
# with the three *external downloads* made tolerant of a TLS-inspecting proxy
# (corporate MITM -> "SSL certificate problem: self signed certificate in
# certificate chain" inside the container):
#   1. gosu   : curl -k  (and the build continues if the download fails)
#   2. Go     : wget --no-check-certificate (and the build continues on failure;
#               the ECS2100 project does not need Go any more)
#   3. pip    : --trusted-host pypi.org/files.pythonhosted.org (continues on failure)
# If you *do* have the corporate CA bundle, prefer baking it in instead:
#   COPY corp-ca.crt /usr/local/share/ca-certificates/corp-ca.crt
#   RUN update-ca-certificates
# and keep strict TLS (drop the -k / --no-check-certificate below).
# ---------------------------------------------------------------------------
FROM ubuntu:20.04
ARG WORKDIR="/work"
RUN apt-get update --fix-missing
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils build-essential sudo git libelf-dev bc vim locales libncurses5-dev wget cpio python2 unzip rsync tzdata
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common libssl-dev gawk device-tree-compiler autoconf sbsigntool flex bison curl python3-pip
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y default-jdk
RUN echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN echo '%sudo ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN useradd -m user --home-dir $WORKDIR && echo "user:user" | chpasswd && adduser user sudo

# Install gosu (tolerant: the image stays usable without it, see entrypoint.sh)
RUN  curl -k -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.17/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    || echo "WARN: gosu could not be downloaded -- run the container with USER_ID=0, entrypoint.sh falls back to setpriv"

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
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

#python3 package (tolerant of a MITM proxy too)
RUN python3 -m pip install \
        --trusted-host pypi.org --trusted-host files.pythonhosted.org --trusted-host pypi.python.org \
        cryptography pyyaml filelock meson==0.56.2 pyelftools \
    || echo "WARN: python3 -m pip install failed -- continuing"

#perl package
RUN apt-get install -y libclone-perl libyaml-perl libmoo-perl liblist-moreutils-perl libdata-compare-perl libmoosex-role-strict-perl libnamespace-autoclean-perl libjson-xs-perl

#python2 package
#RUN apt-get install -y python-yaml

##make python3 default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python2 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 2 \
    && update-alternatives --set python /usr/bin/python3

#Other project depend package
#lsdk2108
RUN apt-get clean
RUN apt-get update
RUN apt-get install -y \
        gettext autopoint \
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
# --- install Go lang (optional for this project; a blocked go.dev must not
#     break the image build) ---
ARG GO_VERSION=1.22.3
ARG GO_BINARY_URL=https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
RUN ( wget -q --no-check-certificate ${GO_BINARY_URL} -O go.tar.gz \
      && tar -C /usr/local -xzf go.tar.gz \
      && rm -f go.tar.gz ) \
    || echo "WARN: Go could not be downloaded -- not needed by the ECS2100 build"

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"
RUN mkdir -p /go && chmod 777 /go
# --- end install Go lang ---
#example usage:
#DOCKER_IMAGE=ubuntu_dev
#docker build --tag ${DOCKER_IMAGE} .
#docker build --tag ${DOCKER_IMAGE} https://github.com/hanger0106/ubuntu_dev.git#20.04:.
#docker run -it --rm  -v /tmp:/tmp -e USER_ID=$(id -u) -e USER_NAME="user" ${DOCKER_IMAGE} bash
 
