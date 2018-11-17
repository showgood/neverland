FROM alpine:latest

MAINTAINER showgood <showgood21@gmail.com>

USER root
COPY sshd_config /etc/ssh/sshd_config
COPY rg /usr/bin/

ENV UID="1000" \
    UNAME="dev" \
    GID="1000" \
    GNAME="dev" \
    SHELL="/bin/bash" \
    UHOME=/home/dev \
    YES="t"

# User
RUN apk --no-cache add sudo \
# Create HOME dir
    && mkdir -p "${UHOME}" \
    && chown "${UID}":"${GID}" "${UHOME}" \
# Create user
    && echo "${UNAME}:x:${UID}:${GID}:${UNAME},,,:${UHOME}:${SHELL}" \
    >> /etc/passwd \
    && echo "${UNAME}::17032:0:99999:7:::" \
    >> /etc/shadow \
# No password sudo
    && echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" \
    > "/etc/sudoers.d/${UNAME}" \
    && chmod 0440 "/etc/sudoers.d/${UNAME}" \
# Create group
    && echo "${GNAME}:x:${GID}:${UNAME}" \
    >> /etc/group

RUN echo "http://nl.alpinelinux.org/alpine/edge/testing" \
    >> /etc/apk/repositories \
    && echo "http://nl.alpinelinux.org/alpine/edge/community" \
    >> /etc/apk/repositories \
    && apk --no-cache --update add \
    bash \
    curl \
    diffutils \
    libice \
    libsm \
    libx11 \
    libxt \
    ncurses \
    git \
    htop \
    ctags \
    libseccomp \
    mosh-server \
    openrc \
    openssh \
    ncurses-terminfo \
    tmux \
    build-base \
    cmake \
    llvm \
    libstdc++ \
    make \
    fontconfig \
    emacs-x11 \
    clang \
    xauth \
    xterm \
    zsh \
    zsh-vcs \
    vim \
    perl \
    shadow # for chsh

# following are needed for install python version
RUN apk --no-cache --update add \
    libffi-dev \
    ncurses-dev \
    openssl-dev \
    readline-dev \
    tk-dev \
    xz-dev \
    zlib-dev \
    sqlite-dev \
    bzip2-dev

RUN rc-update add sshd \
    && rc-status \
    && touch /run/openrc/softlevel \
    && /etc/init.d/sshd start > /dev/null 2>&1 \
    && /etc/init.d/sshd stop > /dev/null 2>&1 \
    && ssh-keygen -A

#              ssh   mosh
EXPOSE 80 8080 62222 60001/udp
