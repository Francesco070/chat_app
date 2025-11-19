# ---- BUILD STAGE ----
FROM hexpm/elixir:1.18.2-erlang-26.2.5.7-alpine-3.18.9 AS build

RUN apk add --no-cache build-base git

WORKDIR /app

ENV MIX_ENV=prod

# Install Hex + Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy dependency files
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy application code
COPY lib ./lib
COPY config ./config

# Compile and build release
RUN mix compile
RUN mix release chat_app --overwrite

# ---- RELEASE STAGE ----
FROM alpine:3.18

RUN apk add --no-cache bash openssl ncurses-libs libstdc++ libgcc

WORKDIR /app

COPY --from=build /app/_build/prod/rel/chat_app ./

RUN chmod -R 755 /app

ENV PORT=4040
ENV MIX_ENV=prod

EXPOSE 4040

CMD ["/app/bin/chat_app", "start"]