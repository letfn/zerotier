SHELL := /bin/bash

menu:
	@perl -ne 'printf("%10s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile

build: # Build defn/zerotier
	docker build -t defn/zerotier .

push: # Push defn/zerotier
	docker push defn/zerotier

bash: # Run bash shell with defn/zerotier
	docker run --rm -ti --entrypoint bash defn/zerotier

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

env:
	docker run --rm -v env_zerotier:/secrets alpine cat /secrets/.env > .env
