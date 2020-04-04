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

## initial join

    docker-compose exec zerotier zerotier-cli join YYYYYY
    docker-compose exec zerotier zerotier-cli listnetworks

### alternative: with zerotier /data

    rsync -ia /data/. data/.

## configure docker with zerotier ipv6 network

    make daemon.json > /etc/docker/daemon.json
    systemctl restart docker

## persist zerotier node identity

    rsync -ia /data/. data/.

## example container with zerotier ipv6 address

    docker run -d --name ubuntu ubuntu sleep 3600
    docker inspect ubuntu | jq -r '.[].NetworkSettings.Networks.bridge.GlobalIPv6Address'

