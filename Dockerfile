FROM ubuntu:24.04

RUN apt-get update && apt-get install -y jekyll

WORKDIR /jekyll/

COPY . .
RUN sed -i 's/"\/tmrc-web"//g' _config.yml

RUN jekyll build

FROM nginx
COPY --from=0 /jekyll/_site/ /usr/share/nginx/html/
RUN apt install -y python3 python3-venv libaugeas0
RUN python3 -m venv /opt/certbot/
RUN /opt/certbot/bin/pip install --upgrade pip
RUN /opt/certbot/bin/pip install certbot certbot-nginx
RUN ln -s /opt/certbot/bin/certbot /usr/bin/certbot
RUN certbot --nginx

EXPOSE 80 443

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]







