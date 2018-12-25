#!/bin/bash
passwd 

adduser adrienm
adduser adrienm sudo

apt-get update
apt-get upgrade

apt-get install -y fail2ban ufw nano deborphan apt-utils build-essential bridge-utils git sudo apt-transport-https ca-certificates curl software-properties-common

curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh

apt-get update
apt-get install docker-ce

apt-get autoremove
apt-get remove --purge `deborphan`


ufw allow 22 && ufw allow 80 && ufw allow 8080
ufw enable

service fail2ban restart
locale-gen fr_FR.UTF-8

echo "complete -cf sudo" >> /home/adrienm/.bashrc
echo "bind 'set match-hidden-files off'" >> /home/adrienm/.bashrc
echo "alias up='sudo apt update && sudo apt upgrade && sudo apt dist-upgrade && sudo apt autoremove'" >> /home/adrienm/.bashrc

su adrienm

mkdir -p /home/adrienm/data/rancher/
mkdir -p /home/adrienm/Script/

#Ajout utilisateur au group docker pour lancement sans sudo
sudo groupadd docker
sudo usermod -aG docker $USER
#
#Copier le dossier data depuis la sauvegarde via scp
#
##to modify
#scp -R root@old.wheretogo.fr:/data/rancher /home/adrienm/data
#scp -R root@old.wheretogo.fr:/data/rancher-active-proxy /home/adrienm/data
#scp -R root@old.wheretogo.fr:/data/arbnode /home/adrienm/data
#Creer une archive pour garder la structure
ssh -t adrienm@old.wheretogo.fr "sudo tar -zcvf archive.tar.gz data/rancher data/rancher-active-proxy/ data/arbnode/"
scp -R adrienm@old.wheretogo.fr:~/archive.tar.gz /home/adrienm/archive.tar.gz
sudo tar -zxvf archive.tar.gz
#Remettre les bons droits
sudo chown -R 102:105 /home/adrienm/data/rancher

#Remove useless DNS service for iodined to work
sudo sh -c 'echo "DNSStubListener=no" >> /etc/systemd/resolved.conf'
sudo systemctl daemon-reload
sudo systemctl restart systemd-resolved.service

#Lancement Rancher
docker run -d -v /home/adrienm/data/rancher/:/var/lib/mysql --restart=unless-stopped -p 8080:8080 --name=rancher-server -l rap.host=ad.wheretogo.fr -l rap.port=8080 -l rap.le_host=ad.wheretogo.fr -l  rap.le_email=amaurel90@gmail.com -l io.rancher.container.pull_image=always rancher/server
#Docker Cheats
#docker rm -f $(docker ps -a -q)
#docker rmi $(docker images -q)
#docker volume ls -qf dangling=true | xargs -r docker volume rm