FROM ubuntu:24.04

RUN apt-get update && apt-get install -y jekyll

WORKDIR /jekyll/

COPY . .
RUN sed -i 's/"\/tmrc-web"//g' _config.yml

RUN jekyll build

FROM nginx
COPY --from=0 /jekyll/_site/ /usr/share/nginx/html/
RUN echo "#!/bin/sh" >> /entrypoint.sh
RUN echo "nginx -g 'daemon off; &'" >> /entrypoint.sh
RUN echo "/usr/bin/certbot -v --non-interactive --agree-tos -m tmrc-web@mit.edu --nginx -d tmrc.mit.edu" >> /entrypoint.sh
RUN echo "tail -f /dev/null" >> /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN apt-get update && apt-get install -y python3 python3-venv libaugeas0 nginx
RUN python3 -m venv /opt/certbot/
RUN /opt/certbot/bin/pip install --upgrade pip
RUN /opt/certbot/bin/pip install certbot certbot-nginx
RUN ln -s /opt/certbot/bin/certbot /usr/bin/certbot
COPY nginx.conf /etc/nginx/conf.d/default.conf
# RUN printf "server {\n    listen 80;\n    server_name tmrc.mit.edu;\n 	  access_log logs/ tmrc.mit.edu.access.log main;\n    root /usr/share/nginx/html/ tmrc.mit.edu/;\n}" >> /etc/nginx/nginx.conf
# RUN nginx -T

EXPOSE 80 443

STOPSIGNAL SIGQUIT

CMD ["/entrypoint.sh"]







