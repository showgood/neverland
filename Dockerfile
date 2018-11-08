FROM alpine:latest

MAINTAINER showgood <showgood21@gmail.com>

USER root
COPY sshd_config /etc/ssh/sshd_config
COPY tmux.conf $UHOME/.tmux.conf
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
    python \
    tmux \
    build-base \
    cmake \
    go \
    llvm \
    libstdc++ \
    make \
    fontconfig \
    emacs-x11 \
    clang \
    xauth \
    xterm \
    zsh \
    perl \
    py2-pip \
    && git clone https://github.com/tmux-plugins/tmux-yank.git \
    $UHOME/.tmux/tmux-yank \
    && pip install powerline-status

RUN rc-update add sshd \
    && rc-status \
    && touch /run/openrc/softlevel \
    && /etc/init.d/sshd start > /dev/null 2>&1 \
    && /etc/init.d/sshd stop > /dev/null 2>&1

USER $UNAME
RUN mkdir -p ~/.local/share/fonts \
    && cd ~ \
    && git clone https://github.com/showgood/tldr.git ~/tldr \
    && git clone https://github.com/showgood/myelpa.git ~/myelpa \
    && git clone https://github.com/showgood/doom-emacs.git ~/.emacs.d \
    && cp ~/.emacs.d/modules/private/showgood/fonts/SF_Mono/*.* ~/.local/share/fonts \
    && cp ~/.emacs.d/modules/private/showgood/fonts/all_the_icons/*.* ~/.local/share/fonts \
    && fc-cache -v \
    && cd ~/.emacs.d \
    && git checkout my_dev \
    && git clone https://github.com/showgood/doom.d.git ~/.doom.d \
    && cd ~/.emacs.d \
    && make install \
    && make autoloads

# powerfont for zsh theme
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
    && cd ~ \
    && git clone https://github.com/powerline/fonts.git --depth=1 \
    && cd fonts \
    && ./install.sh

COPY zshrc $UHOME/.zshrc

USER root
RUN ssh-keygen -A

#              ssh   mosh
EXPOSE 80 8080 62222 60001/udp

ENV TERM=xterm-256color

COPY start.bash /usr/local/bin/start.bash
ENTRYPOINT ["bash", "/usr/local/bin/start.bash"]
