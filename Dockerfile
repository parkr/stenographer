FROM node:10-alpine

WORKDIR /app/stenographer

RUN apk add --no-cache \
  g++ \
  git \
  icu-dev \
  make \
  python2

COPY package* ./

RUN set -ex && npm install && npm audit fix

COPY . .

ENTRYPOINT [ "/app/stenographer/script/hubot" ]
