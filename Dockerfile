FROM fedora:43

LABEL org.opencontainers.image.title="Sandbox dev" \
      org.opencontainers.image.description="Fedora dev sandbox" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.vendor="flavien.io" \
      org.opencontainers.image.maintainer="Flavien PERIER <perier@flavien.io>" \
      org.opencontainers.image.url="https://github.com/flavien-perier/dockerfile-sandbox-dev" \
      org.opencontainers.image.source="https://github.com/flavien-perier/dockerfile-sandbox-dev" \
      org.opencontainers.image.licenses="MIT"

ARG DOCKER_UID="1000" \
    DOCKER_GID="1000" \
    GRAALVM_VERSION="25" \
    MAVEN_VERSION="3.9.12" \
    NODE_VERSION="24.12.0"

ENV PASSWORD="password" \
    JAVA_HOME="/opt/java" \
    MAVEN_HOME="/opt/maven" \
    PATH="/bin:/usr/bin/:/usr/local/bin:/usr/games:/home/admin/bin:/home/admin/.local/bin:/opt/java/bin:/opt/maven/bin:/opt/node/bin"

RUN dnf install -y make gcc clang python3 openssh-server hostname && \
    groupadd -g $DOCKER_GID admin && \
    useradd -g admin -d /home/admin -u $DOCKER_UID admin && \
    curl -s https://sh.flavien.io/shell.sh | sh - && \
    rm -Rf /etc/skel && \
    rm -Rf /home/admin/.config/nvim/ && \
    git clone -q --depth 1 -- https://github.com/LazyVim/starter /home/admin/.config/nvim && \
    rm -Rf /home/admin/.config/nvim/.git && \
    chown -R admin:admin /home/admin && \
    mkdir -p /run/sshd && \
    rm -Rf /tmp/nvim.root && \
    nvim -c ":q" && \
    dnf clean all

RUN mkdir -p /opt/java && \
    export GRAAL_ARCH=`case $(uname -m) in aarch64) echo aarch64;; *) echo x64;; esac` && \
    wget https://download.oracle.com/graalvm/$GRAALVM_VERSION/latest/graalvm-jdk-${GRAALVM_VERSION}_linux-${GRAAL_ARCH}_bin.tar.gz -O /tmp/graalvm.tar.gz && \
    tar xf /tmp/graalvm.tar.gz --strip-components 1 -C /opt/java && \
    rm -f /tmp/.wget* && \
    rm -f /tmp/graalvm.tar.gz

RUN mkdir -p /opt/maven && \
    wget https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -O /tmp/maven.tar.gz && \
    tar xf /tmp/maven.tar.gz --strip-components 1 -C /opt/maven && \
    rm -f /tmp/.wget* && \
    rm -f /tmp/maven.tar.gz

RUN mkdir -p /opt/node && \
    export NODE_ARCH=`case $(uname -m) in aarch64) echo arm64;; *) echo x64;; esac` && \
    wget https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz -O /tmp/node.tar.gz && \
    tar xf /tmp/node.tar.gz --strip-components 1 -C /opt/node && \
    rm -f /tmp/.wget* && \
    rm -f /tmp/node.tar.gz

USER admin
RUN curl -fsSL https://claude.ai/install.sh | bash && \
    rm -f /tmp/.wget* && \
    rm -Rf /home/admin/.npm && \
    rm -Rf /home/admin/.cache && \
    rm -Rf /tmp/node-compile-cache
USER root

WORKDIR /home/admin

EXPOSE 22

COPY --chown=root:root --chmod=500 start.sh /root/start.sh
COPY --chown=admin:admin --chmod=400 claude.settings.json /home/admin/.claude/settings.json

CMD ["/root/start.sh"]
