# Start with Ubuntu 16.04 LTS.
FROM ubuntu:16.04
ARG WORKDIR="/work"
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils build-essential sudo git libelf-dev bc vim locales libncurses5-dev wget cpio python unzip rsync tzdata
RUN apt-get clean all
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
#RUN useradd -m docker --home-dir $WORKDIR && echo "docker:docker" | chpasswd && adduser docker sudo

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
