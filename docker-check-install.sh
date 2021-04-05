#!/usr/bin/env bash

if [[ $(id -u) -ne 0 ]]
then
	echo "Please run this script from root only"
	exit 1
fi

if [[ $(cat /etc/os-release | awk -F= '/NAME=/  && NR==1 { print $2 }' | tr -d '"' | tr [A-Z] [a-z] ) != ubuntu ]]
then
	echo "This script works for only ubuntu"
	echo "Thank you!!!"
	exit 2
fi

if [ -x "$(command -v docker)" ]; then
    echo "Docker is installed already, update if required!"
    # command
else
    echo "Docker not installed, Installing docker"
    # command
    echo "###################################################################################"
    echo "# OS is identified as Ubuntu                                                      #"
    echo "# This Script will remove old docker components and install latest stable docker  #"
    echo "###################################################################################"
    sleep 1
    echo "==> Removing older version of docker if any...."
    apt remove docker docker-engine docker.io containerd runc -y 2>/dev/null

    echo "==> Updating exiting list of packagesss..."
    apt update -y

    echo "==> Installing dependencies......."
    apt install apt-transport-https ca-certificates curl software-properties-common -y

    echo "==> Adding the GPG key for the official Docker repository to your system..."
    #curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    echo y | curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --yes

    echo "==> Adding the Docker repository to APT sources:.."
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y

    echo "==> Update the package database with the Docker packages from the newly added repo..."
    apt update -y

    echo "==> Installing Docker ...."
    apt-cache policy docker-ce docker-ce-cli containerd.io # | head -5

    echo "==> Now installing docker....." 
    apt install docker-ce -y

    if [[ $? -ne 0 ]]
    then
        echo "====>  Sorry Failed to install Docker. Try it manually  <===="
        exit 2
    fi
    echo "====>  Docker has been installed successfully on this host - $(hostname -s)  <===="
    if systemctl status docker &>/dev/null 
    then
        echo "====>  And it is up and running... You can verify it using cmd: systemctl status docker  <===="
    else
        echo "====>  But it is not running. You can start it manually using cmd: systemctl start docker  <===="
    fi

    echo "Sleeping for 5 sec...."
    sleep 5

    echo "==> Now installing docker-compose...."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    echo "Sleeping for 5 sec...."
    sleep 5

    echo "====> Installing elasticsearch in docker container"
    docker-compose up -d

    echo "====> Performing Health Check on elasticsearch"
    sleep 30

    curl http://127.0.0.1:9200/_cat/health
fi
