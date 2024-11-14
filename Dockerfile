FROM ubuntu:24.04

RUN apt-get update && apt-get install -y jekyll

WORKDIR /jekyll/

COPY . .
RUN sed -i 's/"\/tmrc-web"//g' _config.yml

RUN jekyll build

FROM nginx
COPY --from=0 /jekyll/_site/ /usr/share/nginx/html/
RUN echo "#!/bin/sh" >> /entrypoint.sh
RUN echo "nginx -g 'daemon off;' &" >> /entrypoint.sh
RUN echo " sleep 5 && /usr/bin/certbot --non-interactive --agree-tos -m tmrc-web@mit.edu --nginx -d tmrc.mit.edu" >> /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN apt-get update && apt-get install -y python3 python3-venv libaugeas0 nginx
RUN python3 -m venv /opt/certbot/
RUN /opt/certbot/bin/pip install --upgrade pip
RUN /opt/certbot/bin/pip install certbot certbot-nginx
RUN ln -s /opt/certbot/bin/certbot /usr/bin/certbot

EXPOSE 80 443

STOPSIGNAL SIGQUIT

CMD ["/entrypoint.sh"]







