FROM node:18-alpine

WORKDIR /front-app

COPY package-lock.json ./
COPY package.json ./
RUN npm install

COPY public ./public
COPY src ./src

ENV NODE_ENV=development 

RUN npm run build
