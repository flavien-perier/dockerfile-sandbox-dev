FROM debian

LABEL maintainer="Flavien PERIER <perier@flavien.io>"
LABEL version="1.0"
LABEL description="Debian dev sandbox"

ARG DOCKER_UID=500
ARG DOCKER_GID=500

ENV PASSWORD=password

WORKDIR /root
COPY start.sh start.sh

RUN apt-get update && apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y sudo git nodejs python3 python3-pip virtualenv openjdk-11-jdk maven gradle gcc g++ make openssh-client openssh-server && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -q -y && \
    groupadd -g $DOCKER_GID admin && \
    useradd -g admin -m -u $DOCKER_UID admin && \
    echo "admin ALL=(ALL:ALL) ALL" >> /etc/sudoers && \
    curl -s https://raw.githubusercontent.com/flavien-perier/linux-shell-configuration/master/linux-shell-configuration.sh | bash - && \
    /etc/init.d/ssh stop && \
    mkdir /run/sshd && \
    rm -rf /var/lib/apt/lists/* && \
    chown root:root start.sh && \
    chmod 750 start.sh

VOLUME /home/admin

EXPOSE 22
EXPOSE 8080

CMD ./start.sh
