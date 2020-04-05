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

daemon.json:
	@jq -n --arg cidr "$(shell $(MAKE) fixed-cidr-v6)" '{debug: true, experimental: true, ipv6: true, "fixed-cidr-v6": $$cidr}'

fixed-cidr-v6:
	@echo $(shell docker-compose exec zerotier zerotier-cli listnetworks | tail -n +2 | head -1 | awk '{print $$9}' | cut -d, -f1 | cut -d/ -f1 | cut -b1-12)$(shell cut -c 1-2 data/identity.public):$(shell cut -c 3-6 data/identity.public):$(shell cut -c 7-10 data/identity.public)::/80

multipass:
	multipass delete --all --purge || true
	multipass delete --all --purge
	multipass launch -m 500m -d 10g -c 1 -n zt0 --cloud-init cloud-init.conf bionic
	multipass launch -m 500m -d 10g -c 1 -n zt1 --cloud-init cloud-init.conf bionic
	mkdir -p /tmp/data/zerotier/zt0 /tmp/data/zerotier/zt1
	multipass mount /tmp/data/zerotier/zt0 zt0:/data
	multipass mount /tmp/data/zerotier/zt1 zt1:/data

restore:
	mkdir -p work
	git clone https://github.com/letfn/zerotier work/zerotier
	rsync -ia /data/. work/zerotier/data/.
	cd work/zerotier && docker-compose up  -d
	cd work/zerotier && (make daemon.json | sudo tee /etc/docker/daemon.json)
	sudo systemctl restart docker
