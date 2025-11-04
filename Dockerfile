# ---- BUILD STAGE ----
FROM hexpm/elixir:1.18.2-erlang-26.2.5.7-alpine-3.18.9 AS build

RUN apk add --no-cache build-base git

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
ENV MIX_ENV=prod
RUN mix deps.get --only prod
RUN mix deps.compile

COPY lib lib
RUN mix compile

RUN mix release chat_app --overwrite

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

# Non-root user
RUN addgroup -g 1000 chat && \
    adduser -D -s /bin/sh -u 1000 -G chat chat && \
    chown -R chat:chat /app && \
    mkdir -p /app/tmp && chown chat:chat /app/tmp

USER chat

ENV PORT=4040
ENV MIX_ENV=prod
ENV HOME=/app
ENV TMPDIR=/app/tmp
ENV RELEASE_TMP=/app/tmp

EXPOSE 4040

CMD ["/app/bin/chat_app", "start"]
