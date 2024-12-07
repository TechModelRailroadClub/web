run: build
	docker run -d -p 80:80 -p 443:443 --restart unless-stopped nginx-jekyll
build:
	docker build  -t nginx-jekyll .
    
