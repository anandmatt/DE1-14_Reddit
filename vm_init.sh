#!/bin/bash
# Update the apt package index and install packages to allow apt to use a repository over HTTPS:
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker’s official GPG key:
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the stable repository:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Create the docker group if it doesn't already exist and add your user to it
if ! getent group docker > /dev/null; then
  sudo groupadd docker
fi
sudo usermod -aG docker $USER

# Note for user to re-login or restart their session
echo "Please log out and back in or restart your session for the docker group changes to take effect."

# Install Docker Compose (Check https://github.com/docker/compose/releases for the latest version)
DOCKER_COMPOSE_VERSION="v2.24.6" # Update this as needed
mkdir -p ~/.docker/cli-plugins/
curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

# Install Python and pip3
sudo apt update
sudo apt -y upgrade
sudo apt install -y python3-pip

# Upgrade pip to its latest version
sudo pip3 install --upgrade pip

# Install Jupyter Notebook
sudo pip3 install notebook

# Install PySpark
sudo pip3 install pyspark

# Cleanup
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

# End of script
echo "Setup is complete."

