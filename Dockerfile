FROM debian

LABEL maintainer="Flavien PERIER <perier@flavien.io>" \
      version="1.0.0" \
      description="Debian dev sandbox"

ARG DOCKER_UID="500" \
    DOCKER_GID="500"

ENV PASSWORD="password"

WORKDIR /root
VOLUME /home/admin

COPY --chown=root:root start.sh start.sh

RUN apt-get update && apt-get install -y curl && \
    curl -s https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y sudo git nodejs python3 python3-pip virtualenv openjdk-17-jdk maven gradle gcc g++ make openssh-client openssh-server && \
    curl -s https://sh.rustup.rs | bash -s -- -q -y && \
    groupadd -g $DOCKER_GID admin && \
    useradd -g admin -m -u $DOCKER_UID admin && \
    echo "admin ALL=(ALL:ALL) ALL" >> /etc/sudoers && \
    curl -s https://raw.githubusercontent.com/flavien-perier/linux-shell-configuration/master/linux-shell-configuration.sh | bash - && \
    /etc/init.d/ssh stop && \
    mkdir /run/sshd && \
    rm -rf /var/lib/apt/lists/* && \
    chmod 750 start.sh

EXPOSE 22 8080

CMD ./start.sh
