# Start with Ubuntu LTS.
FROM i386/ubuntu:16.04
ARG WORKDIR="/work"

# 修正 16.04 i386 在 old-releases 上的架構指定與來源
RUN echo "deb [arch=i386] http://old-releases.ubuntu.com/ubuntu/ xenial main universe multiverse restricted" > /etc/apt/sources.list && \
    echo "deb [arch=i386] http://old-releases.ubuntu.com/ubuntu/ xenial-security main universe multiverse restricted" >> /etc/apt/sources.list

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils build-essential sudo git libelf-dev bc vim locales libncurses5-dev wget cpio python unzip rsync tzdata bison python3 make
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y libssl-dev gawk device-tree-compiler autoconf sbsigntool flex pkg-config libtool liblz4-tool
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 建立 gmake 的 symbolic link
RUN ln -s /usr/bin/make /usr/bin/gmake

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# 檢查 user 是否存在，若不存在才建立，避免重複建立報錯
RUN id -u user &>/dev/null || (useradd -m user --home-dir $WORKDIR && echo "user:user" | chpasswd && adduser user sudo)

# Install gosu
RUN apt-get update && apt-get -y install curl \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.17/gosu-i386" \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Config TimeZone
RUN TZ=Asia/Taipei \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# ENTRYPOINT
COPY entrypoint.sh /usr/local/bin/entrypoint.sh 
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD [ "/bin/bash" ]
WORKDIR $WORKDIR
ENV WORKDIR=$WORKDIR
RUN mkdir -p /opt && chmod 777 /opt

#default commiter
RUN git config --global user.email "root@project"
RUN git config --global user.name "root"

#example usage:
#DOCKER_IMAGE=ubuntu386_dev
#docker build --tag ${DOCKER_IMAGE} .
#docker build --tag ${DOCKER_IMAGE} https://github.com/hanger0106/ubuntu_dev.git#16.04_386:.
#docker run -it --rm  -v /tmp:/tmp -e USER_ID=1003 -e USER_NAME="user" ${DOCKER_IMAGE} bash
