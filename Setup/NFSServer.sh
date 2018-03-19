#!/bin/bash
#This is for a i386 computer i.e : Server Maison

sudo adduser --disabled-password --gecos "" adrienm
sudo adduser adrienm sudo
sudo sh -c 'echo "adrienm:060190" | chpasswd'

sudo su adrienm

sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get install -y nano deborphan apt-utils build-essential bridge-utils git sudo apt-transport-https ca-certificates curl nfs-commons
sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh

#Ajout utilisateur au group docker pour lancement sans sudo
sudo groupadd docker
sudo usermod -aG docker $USER
sudo usermod -aG docker adrienm

sudo apt-get autoremove -y
sudo apt-get remove -y --purge `deborphan`

echo "complete -cf sudo" >> /home/adrienm/.bashrc
echo "bind 'set match-hidden-files off'" >> /home/adrienm/.bashrc

sudo sh -c "echo '{\"dns\": [\"8.8.8.8\", \"8.8.4.4\"]}' >> /etc/docker/daemon.json"

sudo service docker restart

git clone http://gitlab.com/adi90x/i386-nfs-server

cd i386-nfs-server

mkdir -p /home/adrienm/nfsshare
docker build -t nfsserver .

docker run -d -p 2049:2049 --name nfs --privileged -v /home/adrienm/nfsshare:/nfsshare -e SHARED_DIRECTORY=/nfsshare nfsserver

sudo restart 

#Lancement RancherHostSlave
#sudo docker run --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v1.2.9 http://www.wheretogo.fr:8080/v1/scripts/C3BB37977D64FBC75F84:1514678400000:HJzzKU8PXIg9ltn3NaIei43Y
#Docker Cheats
#docker rm -f $(docker ps -a -q)
#docker rmi $(docker images -q)
#docker volume ls -qf dangling=true | xargs -r docker volume rm
