FROM ubuntu:18.04

# Install some requirements
RUN apt-get update && \
    apt-get install -y python3-pip && \
    apt-get install -y python3-dev && \
    apt-get install -y git && \
    apt-get install -y jq && \
    apt-get install -y wget && \
    apt-get install -y snapd && \
    apt-get install -y curl && \
    apt-get install -y unzip && \
    apt-get install -y git gcc make libpcap-dev sudo

# The working directory where the app will live.
WORKDIR /app

# Copy contents into the app working directory
COPY . /app

# Install all the tools
RUN wget https://dl.google.com/go/go1.19.6.linux-amd64.tar.gz
RUN tar -xvf go1.19.6.linux-amd64.tar.gz
RUN sudo mv go /usr/local
ENV GOROOT=/usr/local/go
ENV GOPATH=$HOME/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# Install all the tools
RUN git clone https://github.com/robertdavidgraham/masscan
RUN cd masscan; make -j ; cd ..
RUN git clone https://github.com/blechschmidt/massdns.git
RUN cd massdns ; make all ; cd ..

RUN wget https://github.com/tomnomnom/assetfinder/releases/download/v0.1.1/assetfinder-linux-amd64-0.1.1.tgz
RUN tar -xvf assetfinder-linux-amd64-0.1.1.tgz
RUN mv assetfinder /bin ; chmod +x /bin/assetfinder

RUN curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip
RUN unzip findomain-linux-i386.zip
RUN chmod +x findomain
RUN sudo mv findomain /usr/bin/findomain

RUN go install -v github.com/tomnomnom/anew@latest
RUN go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
RUN go install -v github.com/cgboal/sonarsearch/crobat@latest
RUN git clone https://github.com/jakejarvis/subtake.git
RUN go install -v github.com/jakejarvis/subtake@latest
RUN go install -v github.com/OWASP/Amass/v3/...@master
RUN go install -v github.com/j3ssie/metabigor@maste


# Install the requirments
RUN pip3 install -r $(pwd)/requirements.txt

# Declare environment variables
ENV FLASK_APP="app.py"
ENV FLASK_ENV=production 

# Run Web app
CMD ["python3", "app.py"]

# Expose the port that Flask is running on
EXPOSE 5444/tcp