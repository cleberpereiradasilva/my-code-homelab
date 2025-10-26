FROM debian:bookworm-slim

# -------------------------------
# Environment & locale
# -------------------------------
RUN apt-get update && apt-get install -y locales && \
    sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen en_US.UTF-8

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV TZ=America/Sao_Paulo

# -------------------------------
# Base packages
# -------------------------------
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    sudo curl wget gnupg git vim zsh tmux unzip tar build-essential \
    openssh-server fonts-powerline ruby-full fontconfig \
    python3 python3-pip python3-venv python3-dev nodejs npm jq ripgrep \
    libtinfo5 libtermkey-dev libvterm-dev libuv1 libmsgpackc2 gettext && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# -------------------------------
# User setup
# -------------------------------
RUN useradd -m -s /usr/bin/zsh noct && \
    echo 'noct ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo 'noct:contem1g' | chpasswd

USER noct
WORKDIR /home/noct

# -------------------------------
# Neovim (latest stable)
# -------------------------------
USER root
RUN rm -rf /opt/nvim && mkdir -p /opt/nvim && \
    curl -Lo /tmp/nvim-linux-x86_64.tar.gz https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.tar.gz && \
    tar -C /opt/nvim -xzf /tmp/nvim-linux-x86_64.tar.gz && \
    ln -sf /opt/nvim/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim && \
    rm /tmp/nvim-linux-x86_64.tar.gz

# -------------------------------
# LazyGit (manual install)
# -------------------------------
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
  | grep -Po '"tag_name": *"v\K[^"]*') && \
  curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
  tar -xzf /tmp/lazygit.tar.gz -C /usr/local/bin lazygit && rm /tmp/lazygit.tar.gz

# -------------------------------
# NVM + Node.js 20
# -------------------------------
USER noct
ENV NVM_DIR=/home/noct/.nvm
RUN mkdir -p $NVM_DIR && \
    curl -L https://github.com/nvm-sh/nvm/archive/refs/tags/v0.40.2.tar.gz | tar -xz -C $NVM_DIR --strip-components=1
RUN bash -c "source $NVM_DIR/nvm.sh && nvm install 20 && nvm alias default 20"
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc

# Fix npm global permissions
USER root
RUN mkdir -p /usr/local/lib/node_modules && chown -R noct:noct /usr/local/lib/node_modules

# -------------------------------
# TypeScript Language Server & utils
# -------------------------------
USER noct
RUN bash -ic "source $NVM_DIR/nvm.sh && npm install -g typescript typescript-language-server prettier eslint"

# -------------------------------
# pnpm + global packages
# -------------------------------
RUN curl -fsSL https://get.pnpm.io/install.sh | bash -s -- --force && \
    echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> ~/.zshrc && \
    echo 'export PATH="$PNPM_HOME:$PATH"' >> ~/.zshrc
ENV PNPM_HOME=/home/noct/.local/share/pnpm
ENV PATH=$PNPM_HOME:$PATH
RUN pnpm add -g vercel typescript


# -------------------------------
# --- Plugins e prompt ZSH --- 
# -------------------------------
USER noct
RUN mkdir -p /home/noct/.zsh
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /home/noct/.zsh/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting /home/noct/.zsh/zsh-syntax-highlighting

# -------------------------------
# colorls (Ruby gem)
# -------------------------------
USER root
RUN gem install colorls

USER noct
# -------------------------------
# Starship prompt
# -------------------------------
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y && \
    mkdir -p ~/.config && \
    starship preset gruvbox-rainbow -o ~/.config/starship.toml

# -------------------------------
# Zsh configuration (.zshrc.part)
# -------------------------------
COPY .zshrc.part /home/noct/.zshrc.part
RUN cat /home/noct/.zshrc.part > /home/noct/.zshrc

# -------------------------------
# LazyVim Neovim config
# -------------------------------
RUN git clone https://github.com/LazyVim/starter /home/noct/.config/nvim

# -------------------------------
# SSH server configuration
# -------------------------------
USER root
RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'AllowUsers noct' >> /etc/ssh/sshd_config && \
    mkdir -p /home/noct/.ssh && chown -R noct:noct /home/noct/.ssh

# -------------------------------
# Expose SSH port
# -------------------------------
EXPOSE 22

# -------------------------------
# Default command to keep container alive
# -------------------------------
CMD ["/usr/sbin/sshd","-D"]


