#!/bin/bash
set -x

# definitions
device={%device%}

sudo apt-get update

# mount disk
mkdir ~/disk
sudo mount /dev/$device ~/disk
ln -s ~/disk/dev ~/dev
ln -s ~/disk/doc ~/doc

sudo gpasswd -a $USER docker
sudo systemctl restart docker

# install nginx and certbot for let's encrypt
cd /etc
sudo cp ~/disk/letsencrypt.tar.gz letsencrypt.tar.gz
sudo tar xzf letsencrypt.tar.gz
cd ~

# install others
mkdir -p ~/.config/nvim
sudo curl https://raw.githubusercontent.com/motojouya/vimrc/master/.vimrc -o ~/.config/nvim/init.vim
sudo chown $USER ~/.vimrc
sudo curl https://raw.githubusercontent.com/motojouya/vimrc/master/.tmux.conf -o ~/.tmux.conf
sudo chown $USER ~/.tmux.conf

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

git config --global core.editor 'vim -c "set fenc=utf-8"'

