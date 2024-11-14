run: build
	docker run -P nginx-jekyll
build:
	docker build  -t nginx-jekyll .
    