run: build
	docker run -p 80:80 443:443 nginx-jekyll
build:
	docker build  -t nginx-jekyll .
    