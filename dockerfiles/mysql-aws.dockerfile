# Dockerfile with the MySQL client and AWS CLI.
# Author: Andrew Jarombek
# Date: 10/10/2020

FROM python:3.9

LABEL maintainer="andrew@jarombek.com" \
      version="1.0.0" \
      description="Dockerfile with the MySQL client and AWS CLI"

RUN apt-get update \
    && pip install --upgrade pip \
    && pip install awscli \
    && apt-get install -y default-mysql-client

ENTRYPOINT ["sleep", "infinity"]