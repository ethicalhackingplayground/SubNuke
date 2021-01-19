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
wget https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz
tar -xvf go1.13.4.linux-amd64.tar.gz
mv go /usr/local
GOROOT=/usr/local/go
GOPATH=$HOME/go
PATH=$GOPATH/bin:$GOROOT/bin:$PATH
git clone https://github.com/blechschmidt/massdns.git
cd massdns ; make all ; cd ..
wget https://github.com/projectdiscovery/subfinder/releases/download/v2.4.5/subfinder_2.4.5_linux_amd64.tar.gz
tar -xzvf subfinder_2.4.5_linux_amd64.tar.gz
mv subfinder  /usr/local/bin
go get github.com/cgboal/sonarsearch/crobat
git clone https://github.com/jakejarvis/subtake.git
go get github.com/jakejarvis/subtake
wget https://github.com/OWASP/Amass/releases/download/v3.10.5/amass_linux_amd64.zip
unzip amass_linux_amd64.zip
cp amass_linux_amd64/amass /bin
go get -u github.com/j3ssie/metabigor

# Install the requirments
pip3 install -r requirements.txt
}

install