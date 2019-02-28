FROM node:10-alpine
WORKDIR /app/stenographer
RUN apk add --no-cache \
  g++ \
  git \
  icu-dev \
  make \
  python2
RUN set -ex && adduser -D -u 1001 stenographer && chown -R stenographer /app/stenographer
USER stenographer
COPY package* /app/stenographer/
RUN set -ex && npm install && npm audit fix
COPY *.json /app/stenographer/
COPY script/hubot /app/stenographer/script/hubot

FROM node:10-alpine
RUN set -ex && adduser -D -u 1001 stenographer
USER stenographer
COPY --from=0 --chown=stenographer /app/stenographer/ /app/stenographer
WORKDIR /app/stenographer
ENTRYPOINT [ "/app/stenographer/script/hubot" ]
