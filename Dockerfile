# ---- BUILD STAGE ----
FROM hexpm/elixir:1.18.2-erlang-26.2.5.7-alpine-3.18.9 AS build

RUN apk add --no-cache build-base git

WORKDIR /app

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get --only prod
RUN mix deps.compile

COPY . .
RUN mix compile
RUN mix release chat_app --overwrite

# ---- RELEASE STAGE ----
FROM alpine:3.18

RUN apk add --no-cache bash openssl ncurses-libs libstdc++ libgcc

# Create non-root user
RUN addgroup -g 1000 chatapp && \
    adduser -D -u 1000 -G chatapp chatapp

WORKDIR /app

COPY --from=build --chown=1000:1000 /app/_build/prod/rel/chat_app ./

# Create and set permissions for tmp directory
RUN mkdir -p /tmp && chown -R 1000:1000 /tmp

USER 1000

ENV PORT=4040
ENV MIX_ENV=prod
ENV RELEASE_TMP=/tmp

EXPOSE 4040

CMD ["/app/bin/chat_app", "start"]