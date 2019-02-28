FROM node:10-alpine

WORKDIR /app/stenographer

RUN apk add --no-cache \
  g++ \
  git \
  icu-dev \
  make \
  python2

RUN set -ex && adduser -D stenographer && chown -R stenographer /app/stenographer
USER stenographer

COPY package* ./

RUN set -ex && npm install && npm audit fix

COPY . .

ENTRYPOINT [ "/app/stenographer/script/hubot" ]
