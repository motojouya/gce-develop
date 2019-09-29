#!/bin/bash
set -x

# definitions
device=$1

sudo apt-get update

# mount disk
mkdir ~/disk
sudo mount $device ~/disk
ln -s ~/disk/dev ~/dev
ln -s ~/disk/doc ~/doc

gpasswd -a $USER docker
systemctl restart docker

# install nginx and certbot for let's encrypt
cd /etc
sudo cp ~/disk/letsencrypt.tar.gz letsencrypt.tar.gz
sudo tar xzf letsencrypt.tar.gz
cd ~

# install others
curl https://raw.githubusercontent.com/motojouya/vimrc/master/.vimrc -o ~/.vimrc
curl https://raw.githubusercontent.com/motojouya/vimrc/master/.tmux.conf -o ~/.tmux.conf

git config --global core.editor 'vim -c "set fenc=utf-8"'

