build-jsmin:
	docker build . -t jsmin-module:amd64 -f Dockerfile-jsmin --network host --progress plain --platform amd64
	docker run --rm -v $(pwd)/result/amd64:/data/amd64 jsmin-module:amd64 cp /result/* /data/amd64

	docker build . -t jsmin-module:arm64 -f Dockerfile-jsmin --network host --progress plain --platform arm64
	docker run --rm -v $(pwd)/result/arm64:/data/arm64 jsmin-module:amd64 cp /result/* /data/arm64