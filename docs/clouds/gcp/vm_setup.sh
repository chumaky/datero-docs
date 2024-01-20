#!/usr/bin/env bash

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install the latest version of Docker Engine and containerd:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# After installation you will have docker installed but available only via sudo. 
# To execute docker commands without sudo you should have add your user to the docker group.
sudo usermod -aG docker $USER

# To apply the group membership, either log out and log back in, 
# or use the following command to activate the group membership in the current session:
newgrp docker

# optionally, list groups current user is a member of.
# you should see a "docker" entry in the list.
# example output: docker adm dialout cdrom floppy audio dip video plugdev netdev lxd ubuntu google-sudoers "your_user"
groups
