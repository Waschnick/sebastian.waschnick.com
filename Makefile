.PHONY: build start

setup:
	brew install hugo

deploy: build upload

upload:
	AWS_PROFILE=waschi aws s3 sync ./public s3://sebastian.waschnick.com
	AWS_PROFILE=waschi aws cloudfront create-invalidation --distribution-id E2R7DAI3A3LS13 --paths "/*"

build:
	HUGO_ENV="production" hugo --baseURL "https://sebastian.waschnick.com"

pre-build:
	bash scripts/optimize_images.sh

build-dev:
	hugo --minify --buildFuture --buildExpired --buildDrafts --baseURL "https://staging.waschnick.com" --config  config.toml,config-dev.toml

start: start-dev
start-dev:
	hugo server --buildFuture --buildExpired --buildDrafts -p 8080 --config config.toml

start-prod:
	HUGO_ENV="production" hugo server -p 8080
