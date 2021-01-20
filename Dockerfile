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
    apt-get install -y git gcc make libpcap-dev

# The working directory where the app will live.
WORKDIR /app

# Copy contents into the app working directory
COPY . /app

# Install all the tools
RUN git clone https://github.com/robertdavidgraham/masscan
RUN cd masscan; make -j ; cd ..
RUN wget https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz
RUN tar -xvf go1.13.4.linux-amd64.tar.gz
RUN mv go /usr/local
ENV GOROOT=/usr/local/go
ENV GOPATH=$HOME/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH
RUN git clone https://github.com/blechschmidt/massdns.git
RUN cd massdns ; make all ; cd ..
RUN wget https://github.com/projectdiscovery/subfinder/releases/download/v2.4.5/subfinder_2.4.5_linux_amd64.tar.gz
RUN tar -xzvf subfinder_2.4.5_linux_amd64.tar.gz
RUN mv subfinder  /usr/local/bin
RUN go get github.com/cgboal/sonarsearch/crobat
RUN git clone https://github.com/jakejarvis/subtake.git
RUN go get github.com/jakejarvis/subtake
RUN wget https://github.com/OWASP/Amass/releases/download/v3.10.5/amass_linux_amd64.zip
RUN unzip amass_linux_amd64.zip
RUN cp amass_linux_amd64/amass /bin
RUN go get -u github.com/j3ssie/metabigor

# Install the requirments
RUN pip3 install -r requirements.txt 

# Declare environment variables
ENV FLASK_APP="app.py"
ENV FLASK_ENV=production 

# Run Web app
CMD ["python3", "app.py"]

# Expose the port that Flask is running on
EXPOSE 5444/tcp