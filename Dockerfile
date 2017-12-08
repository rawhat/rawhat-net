#FROM ubuntu:16.04

#WORKDIR /usr/src/app

#COPY package*.json ./

#RUN apt update
#RUN apt install -y sudo curl
#RUN curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
#RUN apt install -y nodejs build-essential

#RUN npm install

#ENTRYPOINT /bin/bash
FROM node:latest

WORKDIR /usr/src/app

COPY package*.json

RUN npm install

ENTRYPOINT /bin/bash
