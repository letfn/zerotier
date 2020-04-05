SHELL := /bin/bash

.PHONY: docs

menu:
	@perl -ne 'printf("%10s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile | sort -b

all: # Run everything except build
	$(MAKE) fmt
	$(MAKE) lint
	$(MAKE) docs
	$(MAKE) test

fmt: # Format drone fmt
	@echo
	drone exec --pipeline $@

lint: # Run drone lint
	@echo
	drone exec --pipeline $@

test: # Run tests
	@echo
	drone exec --pipeline $@

docs: # Build docs
	@echo
	drone exec --pipeline $@

build: # Build container
	@echo
	drone exec --pipeline $@ --secret-file ../.drone.secret

daemon.json: fixed-cidr-v6
	@jq -n --arg cidr "$(shell cat fixed-cidr-v6)" '{debug: true, experimental: true, ipv6: true, "fixed-cidr-v6": $$cidr}' > daemon.json.1 && mv daemon.json.1 daemon.json
	rm -f fixed-cidr-v6

fixed-cidr-v6:
	@echo $(shell docker-compose exec zerotier zerotier-cli listnetworks | tail -n +2 | head -1 | awk '{print $$9}' | cut -d, -f1 | cut -d/ -f1 | cut -b1-12)$(shell docker-compose exec zerotier cut -c 1-2 /var/lib/zerotier-one/identity.public):$(shell docker-compose exec zerotier cut -c 3-6 /var/lib/zerotier-one/identity.public):$(shell docker-compose exec zerotier cut -c 7-10 /var/lib/zerotier-one/identity.public)::/80 > fixed-cidr-v6.1 && mv fixed-cidr-v6.1 fixed-cidr-v6

zt0 zt1:
	multipass delete --purge $@ || true
	multipass launch -m 4g -d 20g -c 2 -n $@ --cloud-init cloud-init.conf bionic
	multipass mount /tmp/data/$@ $@:/data
	multipass exec $@ -- git clone https://github.com/amanibhavam/homedir homedir
	multipass exec $@ -- mv homedir/.git . && rm -rf homedir && git reset --hard
	multipass exec $@ -- make asdf
	multipass exec $@ -- make update
	multipass exec $@ -- make upgrade
	multipass exec $@ -- make install
	multipass exec $@ -- mkdir -p work
	multipass exec $@ -- git clone https://github.com/letfn/zerotier work/zerotier
	multipass exec $@ -- docker pull letfn/zerotier
	multipass exec $@ -- docker-compose up  -d
	multipass exec $@ -- make daemon.json
	multipass exec $@ -- sudo mv daemon.json /etc/docker/daemon.json
	multipass exec $@ -- sudo systemctl restart docker
