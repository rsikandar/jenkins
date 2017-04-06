#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
sudo apt-get install -y openjdk-7-jdk
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install -y jenkins

sudo service nginx start


