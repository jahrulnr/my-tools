IMAGE_NAME=mountpoint-s3

build:
	docker build -f Dockerfile --tag ${ IMAGE_NAME }:amd64 --platform amd64 .

build-arm:
	docker build -f Dockerfile --tag ${ IMAGE_NAME }:arm64 --platform arm64 .