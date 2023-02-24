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

wget https://github.com/tomnomnom/assetfinder/releases/download/v0.1.1/assetfinder-linux-amd64-0.1.1.tgz
tar -xvf assetfinder-linux-amd64-0.1.1.tgz
mv assetfinder /bin ; chmod +x /bin/assetfinder

curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip
unzip findomain-linux-i386.zip
chmod +x findomain
sudo mv findomain /usr/bin/findomain

go install -v github.com/tomnomnom/anew@latest
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/cgboal/sonarsearch/crobat@latest
git clone https://github.com/jakejarvis/subtake.git
go install -v github.com/jakejarvis/subtake@latest
go install -v github.com/OWASP/Amass/v3/...@master
go install -v github.com/j3ssie/metabigor@maste


# Install the requirments
pip3 install -r $(pwd)/requirements.txt
}

install
