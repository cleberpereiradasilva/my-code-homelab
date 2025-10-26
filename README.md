# My Docker Home Lab

## How to Build

'''
$ docker build -t local/homelab:1.0 .
'''

## How to Run

'''
$ docker run -it -p 2222:22 -v ./dotfiles/config/nvim:/home/noct/.config/nvim -v ./dotfiles/share:/home/noct/.local/share local/homelab:1.0
'''
