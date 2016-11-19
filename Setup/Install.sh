#!/bin/bash

passwd 

adduser adrienm
adduser adrienm sudo

apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'

apt-get update
apt-cache policy docker-engine
apt-get upgrade
apt-get install -y docker-engine

apt-get install -y fail2ban ufw nano deborphan apt-utils build-essential bridge-utils git  sudo apt-transport-https ca-certificates locale-gen fr_FR.UTF-8
pt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual

apt-get autoremove
apt-get remove --purge `deborphan`

ufw allow 22
ufw enable

service fail2ban restart

echo "complete -cf sudo" >> /home/adrienm/.bashrc
echo "bind 'set match-hidden-files off'" >> /home/adrienm/.bashrc


su adrienm
mkdir /home/adrienm/data/
mkdir /home/adrienm/Script/
mkdir /home/adrienm/www/
