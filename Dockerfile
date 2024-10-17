FROM ubuntu:18.04

# OCI annotations to image
LABEL org.opencontainers.image.authors="Snowdream Tech" \
    org.opencontainers.image.title="Ubuntu Base Image" \
    org.opencontainers.image.description="Docker Images for Ubuntu. (i386,amd64,arm32v5,arm32v7,arm64,mips64le,ppc64le,s390x)" \
    org.opencontainers.image.documentation="https://hub.docker.com/r/snowdreamtech/ubuntu" \
    org.opencontainers.image.base.name="snowdreamtech/ubuntu:latest" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/snowdreamtech/ubuntu" \
    org.opencontainers.image.vendor="Snowdream Tech" \
    org.opencontainers.image.version="12.7" \
    org.opencontainers.image.url="https://github.com/snowdreamtech/ubuntu"

ENV DEBIAN_FRONTEND=noninteractive \
    # keep the docker container running
    KEEPALIVE=0 \
    # Ensure the container exec commands handle range of utf8 characters based of
    # default locales in base image (https://github.com/docker-library/docs/tree/master/ubuntu#locales)
    LANG=C.UTF-8 \
    CARGO_TERM_COLOR=always

WORKDIR /root

RUN set -eux \
    && sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
    && apt-get -y update  \
    && apt-get -y install --no-install-recommends \ 
    procps \
    sudo \
    vim \ 
    unzip \
    xz-utils \
    tzdata \
    openssl \
    wget \
    curl \
    iputils-ping \
    lsof \
    git \
    apt-transport-https \
    ca-certificates \                                                                                                                                                                                                      
    && update-ca-certificates\
    && apt-get -y --purge autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && echo 'export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"' >> /etc/bash.bashrc 

RUN set -eux \
    && apt-get -y update  \
    && apt-get -y install --no-install-recommends \ 
    build-essential \
    libgmp-dev \
    libmpfr-dev \
    libppl-dev \
    libz3-dev \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . "$HOME/.cargo/env" \
    && git clone --recursive https://github.com/lizhuohua/rust-mir-checker.git \
    && cd rust-mir-checker \
    && rustup component add rustc-dev llvm-tools-preview \
    && wget https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.6/clang+llvm-15.0.6-x86_64-linux-gnu-ubuntu-18.04.tar.xz \
    && mkdir -p /opt/clang+llvm-15.0.6-x86_64-linux-gnu-ubuntu-18.04 \
    && tar xvf clang+llvm-15.0.6-x86_64-linux-gnu-ubuntu-18.04.tar.xz -C /opt/clang+llvm-15.0.6-x86_64-linux-gnu-ubuntu-18.04 \
    && rm -rfv clang+llvm-15.0.6-x86_64-linux-gnu-ubuntu-18.04.tar.xz \
    && apt-get -y --purge autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* 


COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]