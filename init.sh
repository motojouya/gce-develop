#!/bin/bash
set -x

# definitions
username=$1
ssh_port=$2
domain=$3
device=$4
project=$5
dns_zone=$6

# start configurations
cd /home/ubuntu

apt-get update
apt-get install -y jq
apt-get install -y neovim
apt-get install -y tmux
apt-get install -y tree
apt-get install -y xauth

# apt-add-repository -y ppa:mizuno-as/silversearcher-ag
# apt-get update -y
# apt-get install -y silversearcher-ag

# apt-get install -y nvme-cli

ip=$(curl http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google")
oauth_token=$(curl http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token?audience=https://develop.$domain/ -H "Metadata-Flavor: Google" | jq -r .access_token)

# # gcloud
# export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
# echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
# curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
# apt-get update
# apt-get install -y google-cloud-sdk

# mount disk
mkdir /home/$username
mount /dev/$device /home/$username

# # register cloud dns
# curl https://raw.githubusercontent.com/motojouya/gce-develop/master/dyndns.tmpl -O
# 
# rrsets=$(curl -H "Referer: https://develop.$domain/" -H "Authorization: Bearer $oauth_token" -H "Content-Type: application/json" https://www.googleapis.com/dns/v1/projects/$project/managedZones/$dns_zone/rrsets)
# len=$(echo $rrsets | jq ".rrsets | length")
# for i in $( seq 0 $(($len - 1)) ); do
#   record_type=$(echo $rrsets | jq -r ".rrsets[$i].type")
#   if [ $record_type = 'A' ]; then
#     privious_a_record=$(echo $rrsets | jq -r ".rrsets[$i].rrdatas[0]")
#     break
#   fi
# done
# 
# sed -e "s/{%IP%}/$privious_a_record/g;s/{%domain%}/$domain/g;s/{%action%}/deletions/g" dyndns.tmpl > delete_resource_record_sets.json
# curl -XPOST -H "Referer: https://develop.$domain/" -H "Authorization: Bearer $oauth_token" -H "Content-Type: application/json" https://www.googleapis.com/dns/v1/projects/$project/managedZones/$dns_zone/changes -d @delete_resource_record_sets.json
# 
# sed -e "s/{%IP%}/$ip/g;s/{%domain%}/$domain/g;s/{%action%}/additions/g" dyndns.tmpl > add_resource_record_sets.json
# curl -XPOST -H "Referer: https://develop.$domain/" -H "Authorization: Bearer $oauth_token" -H "Content-Type: application/json" https://www.googleapis.com/dns/v1/projects/$project/managedZones/$dns_zone/changes -d @add_resource_record_sets.json

# ssh config
curl https://raw.githubusercontent.com/motojouya/gce-develop/master/sshd_config.tmpl -O
sed -e s/{%port%}/$ssh_port/g sshd_config.tmpl > sshd_config.init
cp sshd_config.init /etc/ssh/sshd_config
systemctl restart sshd

# # install nodejs
# apt-get install -y nodejs
# apt-get install -y npm
# 
# curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
# echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
# apt-get update
# apt-get install -y yarn
# npm install -g npx
# npm install -g typescript typescript-language-server
# npm install -g browser-sync
# yarn global add create-react-app

# # install docker
# apt-get install -y \
#     apt-transport-https \
#     ca-certificates \
#     curl \
#     gnupg-agent \
#     software-properties-common
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
# apt-key fingerprint 0EBFCD88
# add-apt-repository \
#    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#    $(lsb_release -cs) \
#    stable"
# apt-get update
# apt-get install -y docker-ce docker-ce-cli containerd.io
# 
# curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
# chmod +x /usr/local/bin/docker-compose
# 
# gpasswd -a $username docker
# systemctl restart docker

# # install nginx and certbot for let's encrypt
# cd /etc
# cp /home/$username/letsencrypt.tar.gz letsencrypt.tar.gz
# tar xzf letsencrypt.tar.gz
# cd /home/ubuntu
# 
# export DEBIAN_FRONTEND=noninteractive
# echo "Asia/Tokyo" > /etc/timezone
# # apt-get install -y tzdata
# dpkg-reconfigure -f noninteractive tzdata
# 
# apt-get install -y nginx
# curl https://raw.githubusercontent.com/motojouya/gce-develop/master/http.conf.tmpl -O
# sed -e s/{%domain%}/$domain/g http.conf.tmpl > http.conf
# cp http.conf /etc/nginx/conf.d/http.conf
# 
# apt-get install -y software-properties-common
# add-apt-repository -y universe
# add-apt-repository -y ppa:certbot/certbot
# apt-get update
# apt-get install -y certbot python-certbot-nginx

# # others
# npm -g install firebase-tools
# /home/$username/.fzf/install --bin

# install library for puppeteer
# apt-get install -y gconf-service libasound2 libatk1.0-0 libatk-bridge2.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget

