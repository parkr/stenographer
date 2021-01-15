FROM node:15-alpine as builder
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
COPY script/health /app/stenographer/script/health

FROM node:15-alpine
RUN set -ex && adduser -D -u 1001 stenographer
USER stenographer
HEALTHCHECK --start-period=1s --interval=30s --timeout=5s --retries=1 \
  CMD [ "/app/stenographer/script/health" ]
COPY --from=builder --chown=stenographer /app/stenographer/ /app/stenographer
WORKDIR /app/stenographer
ENTRYPOINT [ "/app/stenographer/script/hubot" ]
