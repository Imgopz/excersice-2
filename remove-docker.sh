echo "Removing Docker"
apt-get purge docker-ce docker-ce-cli containerd.io -y
rm -rf /var/lib/docker
rm -rf /var/lib/containerd

rm /usr/local/bin/docker-compose