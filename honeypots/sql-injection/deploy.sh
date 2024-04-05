#!/bin/bash

docker build -t sql_injection .
docker rm -f wrestlerbook >/dev/null 2>&1 || true
docker run --name wrestlerbook -itd --restart=unless-stopped -v /etc/localtime:/etc/localtime:ro -v /var/run -p 127.0.0.1:19506:80 wrestlerbook
