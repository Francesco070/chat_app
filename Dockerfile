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

WORKDIR /app

COPY --from=build /app/_build/prod/rel/chat_app ./

RUN chmod -R 777 /app /tmp

ENV PORT=4040
ENV MIX_ENV=prod
ENV TMPDIR=/tmp

EXPOSE 4040

CMD ["/app/bin/chat_app", "start"]
