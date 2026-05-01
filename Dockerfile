FROM fedora:44

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
    MAVEN_VERSION="3.9.15" \
    NODE_VERSION="24.15.0"

ENV PASSWORD="password" \
    JAVA_HOME="/opt/java" \
    MAVEN_HOME="/opt/maven"

RUN dnf install -y make gcc clang python3 openssh-server hostname && \
    groupadd -g $DOCKER_GID admin && \
    useradd -g admin -d /home/admin -u $DOCKER_UID admin && \
    curl -s https://sh.flavien.io/shell.sh | sh - && \
    chown -R admin:admin /home/admin && \
    mkdir -p /run/sshd && \
    rm -Rf /etc/skel /etc/subgid- /etc/subuid- /etc/group- /etc/gshadow- && \
    rm -Rf /var/cache/* /var/spool/mail/admin /var/log/* /var/lib/dnf && \
    rm -Rf /tmp/* && \
    dnf remove -y nodejs22 && \
    dnf clean all

RUN mkdir -p /opt/java && \
    export GRAAL_ARCH=`case $(uname -m) in aarch64) echo aarch64;; *) echo x64;; esac` && \
    wget --config=/dev/null https://download.oracle.com/graalvm/$GRAALVM_VERSION/latest/graalvm-jdk-${GRAALVM_VERSION}_linux-${GRAAL_ARCH}_bin.tar.gz -O /tmp/graalvm.tar.gz && \
    tar xf /tmp/graalvm.tar.gz --strip-components 1 -C /opt/java && \
    rm -f /tmp/.wget* && \
    rm -f /tmp/graalvm.tar.gz && \
    echo "/opt/java/bin" >> /home/admin/.user_paths

RUN mkdir -p /opt/maven && \
    wget --config=/dev/null https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -O /tmp/maven.tar.gz && \
    tar xf /tmp/maven.tar.gz --strip-components 1 -C /opt/maven && \
    rm -f /tmp/.wget* && \
    rm -f /tmp/maven.tar.gz && \
    echo "/opt/maven/bin" >> /home/admin/.user_paths

RUN mkdir -p /opt/node && \
    export NODE_ARCH=`case $(uname -m) in aarch64) echo arm64;; *) echo x64;; esac` && \
    wget --config=/dev/null https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz -O /tmp/node.tar.gz && \
    tar xf /tmp/node.tar.gz --strip-components 1 -C /opt/node && \
    rm -f /tmp/.wget* && \
    rm -f /tmp/node.tar.gz && \
    echo "/opt/node/bin" >> /home/admin/.user_paths

USER admin
RUN curl -fsSL https://claude.ai/install.sh | bash && \
    curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh - && \
    rm -Rf /tmp/* && \
    rm -Rf /home/admin/.npm && \
    rm -Rf /home/admin/.cache && \
    rm -Rf /tmp/node-compile-cache

USER root

WORKDIR /home/admin

EXPOSE 22

COPY --chown=root:root --chmod=500 start.sh /root/start.sh
COPY --chown=admin:admin --chmod=400 claude.settings.json /home/admin/.claude/settings.json

CMD ["/root/start.sh"]
