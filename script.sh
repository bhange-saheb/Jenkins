#!/bin/bash
# This Script is used to install jenkins
# Note always update keys and check jenkins official document for latest update.
# Update package list
sudo apt-get update -y

# Install Java (recommended for current Jenkins releases)
sudo apt-get install -y openjdk-21-jre

# Create keyrings directory
sudo mkdir -p /etc/apt/keyrings

# Download Jenkins 2026 GPG key
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

# Add Jenkins repository
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package list
sudo apt-get update -y

# Install Jenkins
sudo apt-get install -y jenkins

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Verify Jenkins service
sudo systemctl status jenkins --no-pager