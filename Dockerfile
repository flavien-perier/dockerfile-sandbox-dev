FROM debian

LABEL org.opencontainers.image.title="Sandbox dev" \
      org.opencontainers.image.description="Debian dev sandbox" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.vendor="flavien.io" \
      org.opencontainers.image.maintainer="Flavien PERIER <perier@flavien.io>" \
      org.opencontainers.image.url="https://github.com/flavien-perier/dockerfile-sandbox-dev" \
      org.opencontainers.image.source="https://github.com/flavien-perier/dockerfile-sandbox-dev" \
      org.opencontainers.image.licenses="MIT"

ARG DOCKER_UID="1000" \
    DOCKER_GID="1000"

ENV PASSWORD="password"

WORKDIR /root
VOLUME /home/admin

RUN apt-get update && apt-get install -y curl && \
    curl -s https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y sudo git nodejs python3 python3-pip virtualenv openjdk-17-jdk maven gradle gcc g++ make openssh-client openssh-server && \
    curl -s https://sh.rustup.rs | bash -s -- -q -y && \
    groupadd -g $DOCKER_GID admin && \
    useradd -g admin -m -u $DOCKER_UID admin && \
    echo "admin ALL=(ALL:ALL) ALL" >> /etc/sudoers && \
    curl -s https://raw.githubusercontent.com/flavien-perier/linux-shell-configuration/master/linux-shell-configuration.sh | bash - && \
    /etc/init.d/ssh stop && \
    mkdir /run/sshd && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 22 8080

COPY --chown=root:root --chmod=500 start.sh start.sh

CMD ./start.sh
