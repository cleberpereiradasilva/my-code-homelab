FROM debian:bookworm-slim AS base
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get upgrade -y && apt-get install -y \
    sudo \
    curl \
    wget \
    gnupg \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    libssl-dev \
    libffi-dev \
    ca-certificates \
    cmake \
    tar \
    passwd \
    xclip \
    unzip \
    gzip \
    git \
    ripgrep \
    nodejs \
    npm \
    jq \
    zsh \
    ruby-full \
    vim \
    fonts-powerline \
    ripgrep \
    && apt-get clean && apt update

RUN npm install -g corepack
RUN gem install colorls

RUN useradd -m -s /bin/bash noct && \
    echo 'noct:contem1g' | chpasswd && \
    adduser noct sudo

WORKDIR /tmp

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm -rf awscliv2.zip aws


RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    sudo rm -rf /opt/nvim && sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz


RUN curl -L -R -O https://www.lua.org/ftp/lua-5.4.7.tar.gz && \
	tar zxf lua-5.4.7.tar.gz && \
	cd lua-5.4.7 && \
	make all test && \
	mv ./src/lua /usr/bin/lua


ARG GO_VERSION=1.22.1

RUN curl -LO https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
  && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
  && rm go${GO_VERSION}.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:$PATH"

ENV GOPATH="/home/noct/go"
ENV PATH="$GOPATH/bin:$PATH"

RUN mkdir -p "$GOPATH" && chown -R noct:noct "$GOPATH"


RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*') && \
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
	tar xf lazygit.tar.gz lazygit && sudo install lazygit -D -t /usr/local/bin/

COPY ./dotfiles/.local/share/nvim /home/noct/.local/share/nvim

RUN curl -fsSL https://get.pnpm.io/install.sh | bash -s -- --force \
  && echo 'export PNPM_HOME="/home/noct/.local/share/pnpm"' >> /home/noct/.bashrc \
  && echo 'export PATH="$PNPM_HOME:$PATH"' >> /home/noct/.bashrc \
  && export PNPM_HOME="/home/noct/.local/share/pnpm" \
  && export PATH="$PNPM_HOME:$PATH" \
  && . /home/noct/.bashrc \
  && pnpm i -g vercel


USER noct
WORKDIR /home/noct

RUN mkdir /home/noct/.ssh/

RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

ENV NVM_DIR="/home/noct/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash && \
    bash -c "source $NVM_DIR/nvm.sh && nvm install 20 && nvm use 20 && nvm alias default 20"

FROM base
WORKDIR /home/noct

USER root
COPY ./dotfiles/.zshrc .zshrc
COPY ./dotfiles/.p10k.zsh .p10k.zsh

RUN curl -fsSL https://bun.sh/install | bash

RUN chown noct:noct /home/noct/ -R



# install lazyvim on top of neovim 
#RUN git clone https://github.com/LazyVim/starter /home/noct/.config/nvim && \
#    echo 'require("config.cds")' >> /home/noct/.config/nvim/init.lua


#
#COPY ./ssh/id_cleberpereiradasilva /home/noct/.ssh/
#COPY ./ssh/id_arena /home/noct/.ssh/
#RUN chown noct:noct /home/noct/.config/nvim -R


CMD ["zsh"]

