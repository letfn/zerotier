---
title: Overview
toc: true
weight: -1
---
## docker-compose on multipass

    mkdir -p work
    git clone https://github.com/letfn/zerotier work/zerotier
    cd work/zerotier
    docker-compose up  -d
    docker-compose exec zerotier zerotier-cli join YYYYYY
    make daemon.json > /etc/docker/daemon.json
    systemctl restart docker
    docker run -d --name ubuntu ubuntu sleep 3600
    docker inspect ubuntu | jq -r '.[].NetworkSettings.Networks.bridge.GlobalIPv6Address'
