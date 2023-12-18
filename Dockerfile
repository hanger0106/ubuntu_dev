# Start with Ubuntu 20.04 LTS.
FROM ubuntu:20.04
ARG WORKDIR="/work"
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils build-essential sudo git libelf-dev bc vim locales libncurses5-dev wget cpio python2 unzip rsync tzdata
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common libssl-dev gawk device-tree-compiler autoconf sbsigntool flex bison
RUN apt-get clean all
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN useradd -m user --home-dir $WORKDIR && echo "user:user" | chpasswd && adduser user sudo

# Install gosu
RUN apt-get -y install curl \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.11/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
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
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

#python3 package
RUN apt update && apt-get install -y python3-pip \
    && python3 -m pip install cryptography

#make python2 default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python2 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 2 \
    && update-alternatives --set python /usr/bin/python2

#Other project depend package
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y default-jdk
RUN chmod 777 /opt
    
#example usage:
#DOCKER_IMAGE=ubuntu_dev
#docker build --tag ${DOCKER_IMAGE} .
#docker build --tag ${DOCKER_IMAGE} https://github.com/hanger0106/ubuntu_dev.git#20.04:.
#docker run -it --rm  -v /tmp:/tmp -e USER_ID=1003 -e USER_NAME="user" ${DOCKER_IMAGE} bash
