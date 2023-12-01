.PHONY: build start

setup:
	brew install hugo

build:
	HUGO_ENV="production" hugo --baseURL "https://www.zeile7.de"

pre-build:
	bash scripts/optimize_images.sh

build-dev:
	hugo --minify --buildFuture --buildExpired --buildDrafts --baseURL "https://staging.zeile7.de" --config  config.toml,config-dev.toml

start: start-dev
start-dev:
	hugo server --buildFuture --buildExpired --buildDrafts -p 8080 --config config.toml

start-prod:
	HUGO_ENV="production" hugo server -p 8080

crawl-linked:
	bash scripts/crawl_linkedin.sh
