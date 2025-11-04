# ---- BUILD STAGE ----
FROM hexpm/elixir:1.18.2-erlang-26.2.5.7-alpine-3.18.9 AS build

RUN apk add --no-cache build-base git

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./
ENV MIX_ENV=prod
RUN mix deps.get --only prod
RUN mix deps.compile

COPY lib lib

RUN mix compile

RUN mix release chat_app --overwrite

RUN ls -la /app/_build/prod/rel/chat_app/

# ---- RELEASE STAGE ----
FROM alpine:3.18

RUN apk add --no-cache \
    openssl \
    ncurses-libs \
    libstdc++ \
    libgcc \
    bash

WORKDIR /app

COPY --from=build /app/_build/prod/rel/chat_app ./

RUN ls -la /app/ && ls -la /app/bin/

RUN addgroup -g 1000 chat && \
    adduser -D -s /bin/sh -u 1000 -G chat chat && \
    chown -R chat:chat /app && \
    mkdir -p /tmp && \
    chmod 1777 /tmp

USER chat

EXPOSE 4040

ENV PORT=4040
ENV MIX_ENV=prod
ENV HOME=/app

CMD ["/app/bin/chat_app", "start"]