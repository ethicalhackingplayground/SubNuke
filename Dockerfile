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
RUN GOROOT=/usr/local/go
RUN GOPATH=$HOME/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH
# Install the requirments
RUN pip3 install -r $(pwd)/../requirements.txt

# Declare environment variables
ENV FLASK_APP="app.py"
ENV FLASK_ENV=production 

# Run Web app
CMD ["python3", "app.py"]

# Expose the port that Flask is running on
EXPOSE 5444/tcp