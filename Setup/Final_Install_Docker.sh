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

#Installation docker compose
sudo curl -o /usr/bin/docker-compose -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)"
sudo chmod +x /usr/bin/docker-compose

#Nginx Reverse Proxy avec fichier parametrage dans vhost.d
docker run -d  --restart=always -p 80:80 -p 443:443 -e DEFAULT_HOST=wheretogo.fr --name nginx-proxy -v /home/adrienm/data/htpasswd:/etc/nginx/htpasswd -v /home/adrienm/data/vhost.d:/etc/nginx/vhost.d:ro -v /var/run/docker.sock:/tmp/docker.sock:ro -v /home/adrienm/data/certs:/etc/nginx/certs:ro -v /usr/share/nginx/html jwilder/nginx-proxy
#Docker UI 
docker run -d --name uidocker -e VIRTUAL_PORT=9000 -e VIRTUAL_HOST=ui.wheretogo.fr -e LETSENCRYPT_HOST=ui.wheretogo.fr -e LETSENCRYPT_EMAIL=amaurel90@gmail.com --privileged -v /var/run/docker.sock:/var/run/docker.sock uifd/ui-for-docker
#Installation MailU
#En cas de probleme acces => sudo docker-compose run --rm admin python manage.py admin admin wheretogo.fr Azdkopvbn6
cd /data/mailu
docker-compose up -d
cd ..
#Connect nginx-proxy au reseau mailu
docker network connect mail_default nginx-proxy
#Nginx Auto Lets Encrypt certifs 
docker run -d --restart=always --name nginx-letsencrypt -v /home/adrienm/data/vhost.d:/etc/nginx/vhost.d:rw -v /home/adrienm/data/certs:/etc/nginx/certs:rw --volumes-from nginx-proxy -v /var/run/docker.sock:/var/run/docker.sock:ro jrcs/letsencrypt-nginx-proxy-companion
#Iodine
docker run -d --name iodine -p 53:53/udp --cap-add=NET_ADMIN --device /dev/net/tun -e IODINE_HOST=io.wheretogo.fr -e IODINE_PASS=060190 -e IODINE_IP=10.0.0.1 adamant/iodine

#OpenVPN https://memo-linux.com/un-serveur-openvpn-en-moins-de-5-minutes-avec-docker/
#Creation Container stockage clef
docker run --name ovpn-data -v /etc/openvpn busybox
#Creation Fichier config/Clef
docker run --volumes-from ovpn-data --rm kylemanna/openvpn ovpn_genconfig -u udp://vpn.wheretogo.fr
docker run --volumes-from ovpn-data --rm -it kylemanna/openvpn ovpn_initpki
#Lancement Serveur OpenVPN + Creation et export Config AdrienM
docker run  -d --name openvpn --volumes-from ovpn-data -d -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn
docker run --volumes-from ovpn-data --rm -it kylemanna/openvpn easyrsa build-client-full AdrienM nopass
docker run --volumes-from ovpn-data --rm kylemanna/openvpn ovpn_getclient AdrienM > /home/data/AdrienM.ovpn
#Installation WatchTower pour verifier que tt est update
docker run  -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock centurylink/watchtower -i 3600
#Lancement Rancher
docker run -d -v /home/adrienm/data/rancher/:/var/lib/mysql --restart=unless-stopped -p 8080:8080 --name=rancher-server -e VIRTUAL_HOST=ad.wheretogo.fr -e VIRTUAL_PORT=8080 -e LETSENCRYPT_HOST=ad.wheretogo.fr -e LETSENCRYPT_EMAIL=amaurel90@gmail.com rancher/server
#Docker Cheats
#docker rm -f $(docker ps -a -q)
#docker rmi $(docker images -q)
#docker volume ls -qf dangling=true | xargs -r docker volume rm


