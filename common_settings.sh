#!/usr/bin/env bash

sudo apt update -qq >/dev/null 2>&1
sudo apt install -y -qq git vim tree net-tools telnet python3-pip sshpass nfs-common >/dev/null 2>&1
curl -fsSL https://get.docker.com -o get-docker.sh 2>&1
sudo sh get-docker.sh >/dev/null 2>&1
sudo usermod -aG docker vagrant
sudo service docker start
echo "autocmd filetype yaml setlocal ai ts=2 sw=2 et" | sudo tee /home/vagrant/.vimrc > /dev/null
sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
