FROM node:22 AS builder

ARG VITE_BACKEND_URL
ARG VITE_APP_KEY

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

ENV VITE_BACKEND_URL=$VITE_BACKEND_URL
ENV VITE_APP_KEY=$VITE_APP_KEY

RUN npm run build

FROM nginx:stable-alpine

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]