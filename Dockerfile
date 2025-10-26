FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y locales && \
    sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen en_US.UTF-8

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV TZ=America/Sao_Paulo

# --- Base packages ---
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    sudo curl wget gnupg git vim zsh tmux unzip xclip \
    build-essential ca-certificates openssh-server locales \
    python3 python3-pip python3-venv python3-dev \
    nodejs npm jq fonts-powerline ripgrep ruby-full fontconfig && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --- User setup ---
RUN useradd -m -s /usr/bin/zsh noct && \
    echo 'noct ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo 'noct:contem1g' | chpasswd

USER noct
WORKDIR /home/noct

# --- Neovim (última versão oficial) ---
USER root

RUN apt-get update && apt-get install -y \
    libtinfo5 libtermkey-dev libvterm-dev libuv1 libmsgpackc2 gettext && \
    rm -rf /opt/nvim && mkdir -p /opt/nvim && \
    curl -Lo /tmp/nvim-linux-x86_64.tar.gz https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.tar.gz && \
    tar -C /opt/nvim -xzf /tmp/nvim-linux-x86_64.tar.gz && \
    ln -sf /opt/nvim/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim && \
    rm /tmp/nvim-linux-x86_64.tar.gz

# --- LazyGit ---
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \
        grep -Po '"tag_name": *"v\K[^"]*') && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
    tar xf lazygit.tar.gz lazygit && install lazygit -D -t /usr/local/bin/ && rm lazygit.tar.gz lazygit

USER noct

# --- NVM + Node.js ---
ENV NVM_DIR=/home/noct/.nvm

RUN mkdir -p $NVM_DIR && \
    curl -L https://github.com/nvm-sh/nvm/archive/refs/tags/v0.40.2.tar.gz | tar -xz -C $NVM_DIR --strip-components=1

# Carregar nvm e instalar Node 20
RUN bash -c "source $NVM_DIR/nvm.sh && nvm install 20 && nvm alias default 20"

RUN echo '\nexport NVM_DIR="$HOME/.nvm"' >> /home/noct/.zshrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/noct/.zshrc

# --- Corrige permissões de global npm ---
USER root
RUN mkdir -p /usr/local/lib/node_modules && chown -R noct:noct /usr/local/lib/node_modules

# --- TypeScript Language Server & utils ---
USER noct
RUN bash -ic "source $NVM_DIR/nvm.sh && npm install -g typescript typescript-language-server prettier eslint"



# --- pnpm + cache inteligente ---
RUN curl -fsSL https://get.pnpm.io/install.sh | bash -s -- --force && \
    echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> ~/.zshrc && \
    echo 'export PATH="$PNPM_HOME:$PATH"' >> ~/.zshrc

ENV PNPM_HOME="/home/noct/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN pnpm add -g vercel typescript

# --- Instalar Hack Nerd Font ---
RUN mkdir -p $HOME/.local/share/fonts && \
    (curl -fLo "$HOME/.local/share/fonts/HackNerdFont-Regular.ttf" \
      https://objects.githubusercontent.com/github-production-release-asset-2e65be/13494249/1a7e2b2a-58a5-46cc-a5ef-589bcdb74c86?X-Amz-Algorithm=AWS4-HMAC-SHA256 || \
     (echo "⚠️  Fallback: baixando pacote completo de fontes Hack" && \
      curl -L -o /tmp/Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip && \
      unzip -j /tmp/Hack.zip -d $HOME/.local/share/fonts && rm /tmp/Hack.zip)) && \
    fc-cache -fv


# --- Plugins e prompt ZSH ---
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting

# --- Instalar colorls ---
RUN sudo gem install colorls

# --- Instalar Starship (substitui Powerlevel10k) ---
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y && \
    mkdir -p ~/.config && \
    starship preset gruvbox-rainbow -o ~/.config/starship.toml


# --- Zsh configuration ---
RUN echo '\
export LANG=en_US.UTF-8\n\
export LC_ALL=en_US.UTF-8\n\
\n\
# Plugins\n\
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh\n\
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\n\
\n\
# Aliases\n\
alias ls="colorls -la"\n\
alias lg="lazygit"\n\
alias activate="source .env/bin/activate"\n\
\n\
# Starship prompt\n\
eval "$(starship init zsh)"\n\
\n\
# Auto tmux\n\
if [ -z "$TMUX" ]; then\n\
  tmux attach || tmux new\n\
fi\n\
export NVM_DIR="$HOME/.nvm"\n\
\n\
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"\n\
' > ~/.zshrc



# install lazyvim on top of neovim 
RUN git clone https://github.com/LazyVim/starter /home/noct/.config/nvim


# --- SSH server config ---
USER root
RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'AllowUsers noct' >> /etc/ssh/sshd_config && \
    mkdir -p /home/noct/.ssh && chown -R noct:noct /home/noct/.ssh

# --- Expose SSH port ---
EXPOSE 22

# --- Default command: start SSH and Zsh ---
CMD service ssh start && exec zsh




