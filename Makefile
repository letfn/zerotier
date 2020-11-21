SHELL := /bin/bash

menu:
	@perl -ne 'printf("%10s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile

build: # Build defn/dnsmasq
	docker build -t defn/dnsmasq .

push: # Push defn/dnsmasq
	docker push defn/dnsmasq

bash: # Run bash shell with defn/dnsmasq
	docker run --rm -ti --entrypoint bash defn/dnsmasq

clean:
	docker-compose down --remove-orphans

up:
	docker-compose up -d --remove-orphans

down:
	docker-compose rm -f -s

recreate:
	$(MAKE) clean
	$(MAKE) up

logs:
	docker-compose logs -f
