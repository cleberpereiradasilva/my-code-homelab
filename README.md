# 🧪 My Docker Home Lab

A fully isolated, fast, and customized development environment with **Zsh**, **Neovim (LazyVim)**, and **Node.js/NVM** — perfect for developers who want productivity and style inside containers.

<img width="1381" height="995" alt="image" src="https://github.com/user-attachments/assets/d1308358-bf9a-4b2b-96fb-cca7f0b83805" />

<img width="2289" height="2077" alt="image" src="https://github.com/user-attachments/assets/93601094-30fd-4b67-8d04-0a08132036da" />

---

## 🚀 How to Build

```
$ docker build -t local/homelab:1.0 .
```

---

## 🧰 How to Run

```
$ docker run -it -p 2222:22 \
  -v /home/noct/work/homelab/dotfiles/config/nvim:/home/noct/.config/nvim \
  -v /home/noct/work/homelab/dotfiles/share:/home/noct/.local/share \
  -v /home/noct/.ssh:/home/noct/.ssh \
  local/homelab:1.0
```

> 💡 Adjust the mounted volumes (-v) according to your host paths.

---

## 🧩 What’s Included

### ⚙️ Shell & Prompt

- **Zsh** — The default shell, powerful and fast
- **Zsh-Autosuggestions** — Command suggestions from your history
- **Zsh-Syntax-Highlighting** — Real-time syntax highlighting
- **Starship** — Minimal, blazing-fast, and fully customizable prompt
- **Hack Nerd Font** — Icon-friendly developer font for a better terminal experience

---

### 🧙‍♂️ Terminal Experience

- **ColorLS** — Beautiful and colorful `ls` replacement with icons
- **tmux** — Terminal multiplexer for persistent sessions
- **lazygit** — A fast and intuitive TUI for Git operations

---

### 🧠 Editor

- **Neovim (LazyVim)** — Modular configuration ready for TypeScript, LSP, Treesitter, and more
- **LSP Servers** — Includes:
  - `typescript-language-server`
  - `tsserver`
- **Lazy.nvim** — Modern plugin manager
- Plugins and themes are persisted using volume mounts (`.config/nvim` and `.local/share`)

---

### 💻 Node.js & Tools

- **NVM** — Node Version Manager
- **Node.js** (latest LTS)
- **TypeScript** and **TypeScript Language Server** installed globally

```
$ npm install -g typescript typescript-language-server
```

This enables autocompletion, linting, and diagnostics in Neovim.

---

### 🌍 Locale

UTF-8 locale properly configured to avoid warnings:

```
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

---

## 💬 Useful Aliases

```
alias ls="colorls -la"
alias lg="lazygit"
alias activate="source .env/bin/activate"
```

---

## 🌀 Automatic tmux Session

When the container starts, `~/.zshrc` automatically attaches to an existing **tmux** session or creates a new one:

```
if [ -z "$TMUX" ]; then
  tmux attach || tmux new
fi
```

---

## 🧭 Folder Structure

```
dotfiles/
├── config/
│   └── nvim/              # Personal Neovim configuration
├── share/
│   └── ...                # LazyVim plugin cache and data
└── ...
```

---

## 🧡 Extra Tip

To connect via SSH (port 2222):

```
$ ssh -p 2222 noct@localhost
```

---

## 🧾 Tool Summary

| Category    | Tool             | Description                                 |
| ----------- | ---------------- | ------------------------------------------- |
| Shell       | Zsh              | Default shell                               |
| Prompt      | Starship         | Modern, fast prompt                         |
| Git UI      | Lazygit          | Text UI for Git                             |
| Multiplexer | tmux             | Persistent terminal sessions                |
| Editor      | Neovim (LazyVim) | Full-featured setup with LSP and TypeScript |
| Node        | NVM + Node.js    | Version management                          |
| LSP         | tsserver         | TypeScript language support                 |
| Font        | Hack Nerd Font   | Developer font with icons                   |

---

🧩 **Your environment, your style.**  
Built for productivity, elegance, and performance inside Docker.
