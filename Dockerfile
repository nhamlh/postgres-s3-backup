FROM postgres:10-alpine

MAINTAINER Nham Le <lehoainham@gmail.com>

RUN apk add --update py-pip && pip install awscli

COPY backup.sh /backup.sh

ENTRYPOINT ["bash", "backup.sh"]
