---
title: Overview
toc: true
weight: -1
---
## create multipass node

    make zt0

## get on a zerotier node

    multipass shell zt0

### start zerotier

    docker-compose up  -d

## initial join

    docker-compose exec zerotier zerotier-cli join YYYYYY
    docker-compose exec zerotier zerotier-cli listnetworks

## configure docker with zerotier ipv6 network

    make daemon.json | sudo tee /etc/docker/daemon.json
    sudo systemctl restart docker

## persist zerotier node identity

    rsync -ia data/. /data/.

## example container with zerotier ipv6 address

    docker run -d --name ubuntu ubuntu sleep 3600
    docker inspect ubuntu | jq -r '.[].NetworkSettings.Networks.bridge.GlobalIPv6Address'

