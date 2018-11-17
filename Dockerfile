FROM showgood/remote-env-base:latest

MAINTAINER showgood <showgood21@gmail.com>

USER $UNAME

# oh-my-zsh and powerfont for zsh theme
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
    && cd ~ \
    && git clone https://github.com/powerline/fonts.git --depth=1 \
    && cd fonts \
    && ./install.sh

# install tmux
RUN cd ~ \
    && mkdir -p ~/.tmux \
    && git clone https://github.com/showgood/workbench.git \
    && cp ~/workbench/dotfiles/zshrc ~/.zshrc \
    && cp ~/workbench/dotfiles/tmux_conf ~/.tmux.conf \
    && cp ~/workbench/dotfiles/tmux_powerline ~/.tmux/ \
    && git clone https://github.com/tmux-plugins/tmux-yank.git \
       ~/.tmux/tmux-yank

# install pyenv
RUN cd ~ \
    && curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash \
    && echo 'export PATH="/home/dev/.pyenv/bin:$PATH"' >> .zshrc \
    && echo 'eval "$(pyenv init -)"' >> .zshrc \
    && echo 'eval "$(pyenv virtualenv-init -)"' >> .zshrc

ENV HOME /home/dev
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN pyenv install 2.7.15 \
    && pyenv install 3.7.1 \
    && pyenv global 2.7.15 \
    && pyenv rehash

# install autojump
RUN cd ~ \
    && git clone git://github.com/wting/autojump.git \
    && cd autojump \
    && ./install.py \
    && cd ~ \
    &&  echo '[[ -s /home/dev/.autojump/etc/profile.d/autojump.sh ]] && source /home/dev/.autojump/etc/profile.d/autojump.sh' >> .bashrc \
    &&  echo '[[ -s /home/dev/.autojump/etc/profile.d/autojump.sh ]] && source /home/dev/.autojump/etc/profile.d/autojump.sh' >> .zshrc

# almighty emacs
RUN mkdir -p ~/.local/share/fonts \
    && cd ~ \
    && git clone https://github.com/showgood/doom-emacs.git ~/.emacs.d \
    && cp ~/.emacs.d/modules/private/showgood/fonts/SF_Mono/*.* ~/.local/share/fonts \
    && cp ~/.emacs.d/modules/private/showgood/fonts/all_the_icons/*.* ~/.local/share/fonts \
    && fc-cache -v \
    && git clone https://github.com/showgood/tldr.git ~/tldr \
    && git clone https://github.com/showgood/myelpa.git ~/myelpa \
    && cd ~/.emacs.d \
    && git checkout my_dev \
    && git clone https://github.com/showgood/doom.d.git ~/.doom.d \
    && make install \
    && make autoloads

ENV TERM=xterm-256color

USER root
RUN ssh-keygen -A

COPY start.bash /usr/local/bin/start.bash
ENTRYPOINT ["bash", "/usr/local/bin/start.bash"]
