# Dockerfile for building a Jenkins server.
# Author: Andrew Jarombek
# Date: 6/3/2020

FROM jenkins/jenkins:lts

LABEL maintainer="andrew@jarombek.com" \
      version="1.0.1" \
      description="Dockerfile for building a Jenkins server"

USER root
WORKDIR /home/root

# Install Python 3.8
RUN apt-get update \
    && apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev \
    && curl -O https://www.python.org/ftp/python/3.8.2/Python-3.8.2.tar.xz \
    && tar -xf Python-3.8.2.tar.xz \
    && cd Python-3.8.2 \
    && ./configure --enable-optimizations \
    && make -j 4 \
    && make altinstall

# Cleanup after Python 3.8 installation.
RUN rm -f Python-3.8.2.tar.xz

# Install Terraform
RUN mkdir bin \
    && apt-get install -y wget \
    && wget https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip \
    && unzip terraform_0.12.28_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && terraform --version

# Install AWS CLI
RUN pip3.8 install awscli

# Install Node.js
RUN apt-get install -y build-essential libssl-dev

ENV NVM_DIR /usr/local/.nvm
ENV NODE_VERSION 14.4.0

WORKDIR /usr/local/
RUN mkdir .nvm && chown jenkins .nvm
USER jenkins
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash

SHELL ["/bin/bash", "-c"]
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION  \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
ENV PATH $NVM_DIR:$PATH

RUN npm i yarn -g

# Install JQ
USER root
RUN apt-get install -y jq

# Install sudo
RUN apt-get install -y sudo
RUN adduser jenkins sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Configure the Jenkins server with plugins and seed jobs.
COPY jenkins.yaml /usr/share/jenkins/ref/jenkins.yaml
RUN jenkins-plugin-cli --plugins "ansicolor authorize-project build-timeout cloudbees-folder configuration-as-code" \
    && jenkins-plugin-cli --plugins "credentials-binding email-ext envinject git github greenballs job-dsl kubernetes" \
    && jenkins-plugin-cli --plugins "matrix-auth parameterized-scheduler pipeline-build-step pipeline-model-definition" \
    && jenkins-plugin-cli --plugins "pipeline-stage-view rebuild timestamper workflow-cps-global-lib workflow-job ws-cleanup"

USER jenkins
EXPOSE 8080 50000