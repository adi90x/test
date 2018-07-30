#!/bin/bash
passwd 

adduser adrienm
adduser adrienm sudo

apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'

apt-get update
apt-get upgrade


apt-get install -y fail2ban ufw nano deborphan apt-utils build-essential bridge-utils git  sudo apt-transport-https ca-certificates 
apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
apt-get install -y docker-engine

apt-get autoremove
apt-get remove --purge `deborphan`


ufw allow 22
ufw enable

service fail2ban restart
locale-gen fr_FR.UTF-8

echo "complete -cf sudo" >> /home/adrienm/.bashrc
echo "bind 'set match-hidden-files off'" >> /home/adrienm/.bashrc
echo "alias up='sudo apt update && sudo apt upgrade && sudo apt dist-upgrade && sudo apt autoremove'" >> /home/adrienm/.bashrc

su adrienm
mkdir /home/adrienm/data/
mkdir /home/adrienm/Script/
Ubuntu Server
mkdir /home/adrienm/www/
#Ajout utilisateur au group docker pour lancement sans sudo
sudo groupadd docker
sudo usermod -aG docker $USER
#
#Copier le dossier data depuis la sauvegarde via scp
#
#Lancement Rancher
docker run -d -v /home/adrienm/data/rancher/:/var/lib/mysql --restart=unless-stopped -p 8080:8080 --name=rancher-server -l rap.host=ad.wheretogo.fr -l rap.port=8080 -l rap.le_host=ad.wheretogo.fr -l  rap.le_email=amaurel90@gmail.com -l io.rancher.container.pull_image=always rancher/server
#Docker Cheats
#docker rm -f $(docker ps -a -q)
#docker rmi $(docker images -q)
#docker volume ls -qf dangling=true | xargs -r docker volume rm