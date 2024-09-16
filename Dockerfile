FROM debian:stable

LABEL org.opencontainers.image.title="Sandbox dev" \
      org.opencontainers.image.description="Debian dev sandbox" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.vendor="flavien.io" \
      org.opencontainers.image.maintainer="Flavien PERIER <perier@flavien.io>" \
      org.opencontainers.image.url="https://github.com/flavien-perier/dockerfile-sandbox-dev" \
      org.opencontainers.image.source="https://github.com/flavien-perier/dockerfile-sandbox-dev" \
      org.opencontainers.image.licenses="MIT"

ARG DOCKER_UID="1000" \
    DOCKER_GID="1000" \
    GRAALVM_VERSION="21" \
    NODE_VERSION="20.17.0"

ENV PASSWORD="password"

WORKDIR /root
VOLUME /home/admin

RUN apt-get update && apt-get install -y curl && \
    apt-get install -y sudo git python3 python3-pip virtualenv maven gradle gcc g++ make openssh-client openssh-server && \
    curl -s https://sh.rustup.rs | bash -s -- -q -y && \
    groupadd -g $DOCKER_GID admin && \
    useradd -g admin -m -u $DOCKER_UID admin && \
    echo "admin ALL=(ALL:ALL) ALL" >> /etc/sudoers && \
    curl -s https://sh.flavien.io/shell.sh | bash - && \
    /etc/init.d/ssh stop && \
    mkdir -p /run/sshd && \
    rm -rf /var/lib/apt/lists/*

RUN export GRAAL_ARCH=`case $(uname -m) in aarch64) echo aarch64;; *) echo x64;; esac` && \
    wget https://download.oracle.com/graalvm/$GRAALVM_VERSION/latest/graalvm-jdk-${GRAALVM_VERSION}_linux-${GRAAL_ARCH}_bin.tar.gz -O /tmp/graalvm.tar.gz && \
    tar xf /tmp/graalvm.tar.gz --strip-components 1 -C /usr && \
    rm -f /tmp/graalvm.tar.gz

RUN export NODE_ARCH=`case $(uname -m) in aarch64) echo arm64;; *) echo x64;; esac` && \
    wget https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz -O /tmp/node.tar.gz && \
    tar xf /tmp/node.tar.gz --strip-components 1 -C /usr && \
    rm -f /tmp/node/tar.gz

EXPOSE 22 8080

COPY --chown=root:root --chmod=500 start.sh start.sh

CMD ./start.sh
