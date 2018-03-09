#!/bin/bash
sudo adduser --disabled-password --gecos "" adrienm
sudo adduser adrienm sudo
echo "adrienm:060190" | chpasswd

sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get install -y nano deborphan apt-utils build-essential bridge-utils git sudo apt-transport-https ca-certificates curl
sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh

#Ajout utilisateur au group docker pour lancement sans sudo
sudo groupadd docker
sudo usermod -aG docker $USER


sudo apt-get autoremove -y
sudo apt-get remove -y --purge `deborphan`

echo "complete -cf sudo" >> /home/adrienm/.bashrc
echo "bind 'set match-hidden-files off'" >> /home/adrienm/.bashrc

sudo sh -c "echo '{\"dns\": [\"8.8.8.8\", \"8.8.4.4\"]}' >> /etc/docker/daemon.json"

sudo service docker restart

#Lancement RancherHostSlave
sudo docker run --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v1.2.9 http://www.wheretogo.fr:8080/v1/scripts/C3BB37977D64FBC75F84:1514678400000:HJzzKU8PXIg9ltn3NaIei43Y
#Docker Cheats
#docker rm -f $(docker ps -a -q)
#docker rmi $(docker images -q)
#docker volume ls -qf dangling=true | xargs -r docker volume rm
