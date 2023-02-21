#!/bin/bash
####################################
#
# Subdomain takeover tool installer
#
####################################

function install () {

mkdir -p app
cd app

# Install some requirements
sudo apt-get update && \
sudo apt-get install -y python3-pip && \
sudo apt-get install -y python3-dev && \
sudo apt-get install -y git && \
sudo apt-get install -y jq && \
sudo apt-get install -y wget && \
sudo apt-get install -y curl && \
sudo apt-get install -y unzip && \
sudo apt-get install -y git gcc make libpcap-dev && \
sudo apt-get install -y mariadb-server


# Install all the tools
git clone https://github.com/robertdavidgraham/masscan
cd masscan; make -j ; cd ..
wget https://dl.google.com/go/go1.19.6.linux-amd64.tar.gz
tar -xvf go1.19.6.linux-amd64.tar.gz
sudo mv go /usr/local
GOROOT=/usr/local/go
GOPATH=$HOME/go
PATH=$GOPATH/bin:$GOROOT/bin:$PATH
git clone https://github.com/blechschmidt/massdns.git
cd massdns ; make all ; cd ..
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/cgboal/sonarsearch/crobat@latest
git clone https://github.com/jakejarvis/subtake.git
go install -v github.com/jakejarvis/subtake@latest
go install -v github.com/OWASP/Amass/v3/...@master
go install -v github.com/j3ssie/metabigor@maste

# Install the requirments
pip3 install -r $(pwd)/../requirements.txt
}

install
