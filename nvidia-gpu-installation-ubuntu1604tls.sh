#!/bin/bash

nvidia_driver_version="${NVIDIA_DRIVER_VERSION:-375.39}"
nvidia_docker_version="${NVIDIA_DOCKER_VERSION:-1.0.1}"

# required before installing nvidia driver
sudo apt-get update
sudo apt-get install -y --no-install-recommends -y gcc make libc-dev
sudo apt-get install -y linux-image-extra-virtual

# blacklisting nouveau etc
sudo cp blacklist-nouveau.conf /etc/modprobe.d/
echo options nouveau modeset=0 | sudo tee -a /etc/modprobe.d/nouveau-kms.conf
sudo update-initramfs -u

# install nvidia driver
wget -P /tmp http://us.download.nvidia.com/XFree86/Linux-x86_64/$nvidia_driver_version/NVIDIA-Linux-x86_64-$nvidia_driver_version.run
sudo sh /tmp/NVIDIA-Linux-x86_64-$nvidia_driver_version.run --silent
sudo rm /tmp/NVIDIA-Linux-x86_64-$nvidia_driver_version.run

# install docker
sudo apt-get remove -y docker docker-engine
sudo apt-get update
sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce

# install nvidia-docker and nvidia-docker plugin
wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v$nvidia_docker_version/nvidia-docker_$nvidia_docker_version-1_amd64.deb
sudo dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb
sudo nvidia-docker run --rm nvidia/cuda nvidia-smi && sudo nvidia-docker rmi nvidia/cuda
# sudo docker volume create --name=nvidia_driver_$nvidia_driver_version -d nvidia-docker
sudo docker volume inspect nvidia_driver_$nvidia_driver_version

sudo reboot
