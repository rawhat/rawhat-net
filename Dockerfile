FROM node:latest

WORKDIR /usr/src/app

COPY . .

RUN npm install

RUN npm start

CMD ["node", "server.js"]
