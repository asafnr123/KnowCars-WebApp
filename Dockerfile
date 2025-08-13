
FROM node:18-alpine AS react_build

WORKDIR /front-app

COPY frontend-react/package-lock.json ./
COPY frontend-react/package.json ./
RUN npm install

COPY frontend-react/public ./public
COPY frontend-react/src ./src

RUN npm run build

FROM nginx:alpine

COPY --from=react_build /front-app/build /usr/share/nginx/html

RUN rm /etc/nginx/conf.d/*
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx","-g","daemon off;"]
