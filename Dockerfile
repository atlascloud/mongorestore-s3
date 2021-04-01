FROM alpine:3.13.4

LABEL maintainer "Atlas Cloud Devs <atlas@kws1.com>"

ENV S3_PATH=mongodb AWS_DEFAULT_REGION=us-east-1

RUN apk add --no-cache mongodb-tools py3-pip && \
  pip3 install --no-cache-dir pymongo awscli && \
  mkdir /backup

COPY entrypoint.sh /usr/local/bin/entrypoint
COPY restore.sh /usr/local/bin/restore
COPY mongouri.py /usr/local/bin/mongouri

VOLUME /backup

CMD /usr/local/bin/entrypoint
