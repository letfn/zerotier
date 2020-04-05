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
	@echo $(shell docker-compose exec zerotier zerotier-cli listnetworks | tail -n +2 | head -1 | awk '{print $$9}' | cut -d, -f1 | cut -d/ -f1 | cut -b1-12)$(shell cut -c 1-2 data/identity.public):$(shell cut -c 3-6 data/identity.public):$(shell cut -c 7-10 data/identity.public)::/80 > fixed-cidr-v6.1 && mv fixed-cidr-v6.1 fixed-cidr-v6

multipass:
	multipass delete --all --purge || true
	multipass delete --all --purge
	$(MAKE) zt0
	$(MAKE) zt1

zt0 zt1:
	multipass launch -m 500m -d 10g -c 1 -n $@ --cloud-init cloud-init.conf bionic
	mkdir -p /tmp/data/zerotier/$@ /tmp/data/zerotier/zt1
	multipass mount /tmp/data/zerotier/$@ $@:/data
	multipass exec $@ -- mkdir -p work
	multipass exec $@ -- git clone https://github.com/letfn/zerotier work/zerotier
	multipass exec $@ -- docker pull letfn/zerotier

restore:
	rsync -ia /data/. data/.
	docker-compose up  -d
	make daemon.json
	sudo mv daemon.json /etc/docker/daemon.json
	sudo systemctl restart docker
