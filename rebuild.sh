#!/bin/bash

git pull ; docker build -t subnuke . ; docker stop subnuke ; docker run -d --rm -p 8080:5444 --name subnuke subnuke