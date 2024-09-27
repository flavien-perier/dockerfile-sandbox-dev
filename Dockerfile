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
    MAVEN_VERSION="3.9.9" \
    NODE_VERSION="20.17.0"

ENV PASSWORD="password" \
    JAVA_HOME="/opt/java" \
    MAVEN_HOME="/opt/maven" \
    PATH="${PATH}:/opt/java/bin:/opt/maven/bin:/opt/node/bin"

WORKDIR /root

RUN apt-get update && apt-get install -y sudo curl git openssh-server \
        python3 python3-pip virtualenv make && \
    curl -s https://sh.rustup.rs | bash -s -- -q -y && \
    groupadd -g $DOCKER_GID admin && \
    useradd -g admin -m -u $DOCKER_UID admin && \
    echo "admin ALL=(ALL:ALL) ALL" >> /etc/sudoers && \
    curl -s https://sh.flavien.io/shell.sh | bash - && \
    /etc/init.d/ssh stop && \
    mkdir -p /run/sshd && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/java && \
    export GRAAL_ARCH=`case $(uname -m) in aarch64) echo aarch64;; *) echo x64;; esac` && \
    wget https://download.oracle.com/graalvm/$GRAALVM_VERSION/latest/graalvm-jdk-${GRAALVM_VERSION}_linux-${GRAAL_ARCH}_bin.tar.gz -O /tmp/graalvm.tar.gz && \
    tar xf /tmp/graalvm.tar.gz --strip-components 1 -C /opt/java && \
    rm -f /tmp/graalvm.tar.gz

RUN mkdir -p /opt/maven && \
    wget https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -O /tmp/maven.tar.gz && \
    tar xf /tmp/maven.tar.gz --strip-components 1 -C /opt/maven && \
    rm -f /tmp/maven.tar.gz

RUN mkdir -p /opt/node && \
    export NODE_ARCH=`case $(uname -m) in aarch64) echo arm64;; *) echo x64;; esac` && \
    wget https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz -O /tmp/node.tar.gz && \
    tar xf /tmp/node.tar.gz --strip-components 1 -C /opt/node && \
    rm -f /tmp/node.tar.gz

EXPOSE 22

COPY --chown=root:root --chmod=500 start.sh start.sh

CMD ./start.sh
