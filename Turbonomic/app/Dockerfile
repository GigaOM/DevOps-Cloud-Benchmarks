FROM ubuntu:latest

RUN apt update -y
RUN apt install nodejs -y
RUN apt install npm -y

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000
CMD [ "node", "./bin/www" ]