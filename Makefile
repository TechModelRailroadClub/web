run: build
	docker run -p 80:80 nginx-jekyll
build:
	docker build  -t nginx-jekyll .
    