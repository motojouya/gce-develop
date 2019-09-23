#!/bin/bash
set -x

# definitions
# export AWS_DEFAULT_REGION=asia-northeast1
# asia-northeast1-b

username=$1
ssh_port=$2
hosted_zone_id=$2
domain=$4

ip=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)

cd /home/ubuntu

apt-get update
apt-get install nvme-cli

# gcloud
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y google-cloud-sdk

# mount disk
mkdir /home/$username/work
mount $device /home/$username/work
ln -s /home/$username/work/dev /home/$username/dev
ln -s /home/$username/work/doc /home/$username/doc

# register route53
curl https://raw.githubusercontent.com/motojouya/ec2-develop/master/dyndns.tmpl -O
sed -e "s/{%IP%}/$ip/g;s/{%domain%}/$domain/g" dyndns.tmpl > change_resource_record_sets.json
aws route53 change-resource-record-sets --hosted-zone-id $hosted_zone_id --change-batch file:///home/ubuntu/change_resource_record_sets.json

# ssh config
curl https://raw.githubusercontent.com/motojouya/ec2-develop/master/sshd_config.tmpl -O
sed -e s/{%port%}/$ssh_port/g sshd_config.tmpl > sshd_config.init
cp sshd_config.init /etc/ssh/sshd_config
systemctl restart sshd

# install nodejs
apt-get install -y nodejs
apt-get install -y npm

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt-get update
apt-get install -y yarn
npm install -g npx
npm install -g typescript typescript-language-server
yarn global add create-react-app

# install docker
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

gpasswd -a $username docker
systemctl restart docker

# install nginx and certbot for let's encrypt
cd /etc
cp /home/$username/letsencrypt.tar.gz letsencrypt.tar.gz
tar xzf letsencrypt.tar.gz
cd /home/ubuntu

apt-get install -y nginx
curl https://raw.githubusercontent.com/motojouya/ec2-develop/master/http.conf.tmpl -O
sed -e s/{%domain%}/$domain/g http.conf.tmpl > http.conf
cp http.conf /etc/nginx/conf.d/http.conf

apt-get install -y software-properties-common
add-apt-repository -y universe
add-apt-repository -y ppa:certbot/certbot
apt-get update
apt-get install -y certbot python-certbot-nginx

# install library for puppeteer
# apt-get install -y gconf-service libasound2 libatk1.0-0 libatk-bridge2.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget

# install others
apt-get install -y neovim
apt-get install -y jq
apt-get install -y tree

# git config --global core.editor 'vim -c "set fenc=utf-8"'

