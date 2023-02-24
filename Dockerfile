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
COPY install.sh .
RUN chmod +x install.sh ; ./install.sh

# Install the requirments
RUN pip3 install -r $(pwd)/../requirements.txt

# Declare environment variables
ENV FLASK_APP="app.py"
ENV FLASK_ENV=production 

# Run Web app
CMD ["python3", "app.py"]

# Expose the port that Flask is running on
EXPOSE 5444/tcp