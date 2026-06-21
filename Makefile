run: build
	docker run -d -p 80:80 -p 443:443 --restart unless-stopped nginx-hugo
build:
	docker build -t nginx-hugo .

