# Dockerfile which installs pipenv and exposes the default flask port.
# Author: Andrew Jarombek
# Date: 10/10/2020

FROM python:3.9

LABEL maintainer="andrew@jarombek.com" \
      version="1.0.0" \
      description="Dockerfile which installs pipenv and exposes the default flask port."

RUN pip install pipenv
EXPOSE 5000