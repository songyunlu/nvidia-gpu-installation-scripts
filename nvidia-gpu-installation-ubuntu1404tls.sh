#!/bin/bash

nvidia_driver_version="${nvidia_driver_version:-375.39}"
nvidia_docker_version="${nvidia_docker_version:-1.0.1}"

# required before installing nvidia driver
sudo apt-get update
sudo apt-get install -y --no-install-recommends -y gcc make libc-dev

# Nvidia's driver depends on the drm module, but that's not included in the default
# 'virtual' ubuntu that's on the cloud (as it usually has no graphics).  It's 
# available in the linux-image-extra-virtual package (and linux-image-generic supposedly),
# but just installing those directly will install the drm module for the NEWEST available
# kernel, not the one we're currently running.  Hence, we need to specify the version
# manually.  This command will probably need to be re-run every time you upgrade the
# kernel and reboot.
sudo apt-get install -y linux-image-extra-`uname -r` linux-headers-`uname -r` linux-image-`uname -r`

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
