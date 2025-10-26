# My Docker Home Lab

## How to Build

```
$ docker build -t local/homelab:1.0 .
```

## How to Run

```
$ docker run -it -p 2222:22 -v YOUR_PATH/dotfiles/config/nvim:/home/noct/.config/nvim \
  -v YOUR_PATH/dotfiles/share:/home/noct/.local/share \
  local/homelab:1.0
```

## My Config

```
$ docker run -it -p 2222:22 -v /home/noct/work/homelab/dotfiles/config/nvim:/home/noct/.config/nvim \
  -v /home/noct/work/homelab/dotfiles/share:/home/noct/.local/share -v \
  /home/noct/.ssh:/home/noct/.ssh \
  local/homelab:1.0
```
