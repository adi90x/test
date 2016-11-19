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
mkdir /home/adrienm/www/
#Installation docker compose
sudo curl -o /usr/bin/docker-compose -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)"
sudo chmod +x /usr/bin/docker-compose
####
#Copier tout le folder data ! 
##89.36.220.81
#Ajout utilisateur au group docker pour lancement sans sudo
sudo groupadd docker
sudo usermod -aG docker $USER

#Nginx Reverse Proxy avec fichier parametrage dans vhost.d
docker run  -d --name nginx-proxy -p 80:80 -p 443:443 -e DEFAULT_HOST=wheretogo.fr  -v /home/adrienm/data/htpasswd:/etc/nginx/htpasswd -v /home/adrienm/data/vhost.d:/etc/nginx/vhost.d:ro -v /var/run/docker.sock:/tmp/docker.sock:ro -v /home/adrienm/data/certs:/etc/nginx/certs:ro -v /usr/share/nginx/html jwilder/nginx-proxy
#Nginx Auto Lets Encrypt certifs
docker run -d --name nginx-letsencrypt -v /home/adrienm/data/vhost.d:/etc/nginx/vhost.d:rw -v /home/adrienm/data/certs:/etc/nginx/certs:rw --volumes-from nginx-proxy -v /var/run/docker.sock:/var/run/docker.sock:ro jrcs/letsencrypt-nginx-proxy-companion
#Docker UI 
docker run -d --name dockerui -e VIRTUAL_PORT=9000 -e VIRTUAL_HOST=ui.wheretogo.fr -e LETSENCRYPT_HOST=ui.wheretogo.fr -e LETSENCRYPT_EMAIL=amaurel90@gmail.com --privileged -v /var/run/docker.sock:/var/run/docker.sock uifd/ui-for-docker
#Iodine
docker run -d --name iodine -p 53:53/udp --cap-add=NET_ADMIN --device /dev/net/tun -e IODINE_HOST=io.wheretogo.fr -e IODINE_PASS=060190 -e IODINE_IP=10.0.0.1 adamant/iodine
#Installation MailU
#Pas utile car la db redis est stocké ! sudo docker-compose run --rm admin python manage.py admin admin wheretogo.fr Azdkopvbn6
cd /data/mailu/
docker-compose up -d
docker network connect mail_default nginx-proxy
#Permet de creer rapidos un certificat que l'on peut copier pour les mails // il faudra le mettre ailleur ! 
#https://www.cyberciti.biz/tips/linux-unix-bsd-nginx-webserver-security.html => nginx security
docker run -e VIRTUAL_HOST=wheretogo.fr,mail.wheretogo.fr -e LETSENCRYPT_HOST=wheretogo.fr,mail.wheretogo.fr -e LETSENCRYPT_EMAIL=amaurel90@gmail.com  tutum/apache-php

docker run  -p 80:80 -p 443:443 -e DEFAULT_HOST=wheretogo.fr --name nginx-proxy -v /home/adrienm/data/htpasswd:/etc/nginx/htpasswd -v /home/adrienm/data/vhost.d:/etc/nginx/vhost.d:ro -v /var/run/docker.sock:/tmp/docker.sock:ro -v /home/adrienm/data/certs:/etc/nginx/certs:ro  jwilder/nginx-proxy
 docker run -p 443:443 -p 80:80 --name nginx -v /home/adrienm/data/nginx/conf.d:/etc/nginx/conf.d -v /home/adrienm/data/mailu/certs/:/certs/ -t nginx

docker run  -p 80:80 -p 443:443  --name nginx -v /home/adrienm/data/nginx/conf.d:/etc/nginx/conf.d -v /home/adrienm/data/nginx/html:/usr/share/nginx/html -t nginx