# ---- BUILD STAGE ----
FROM hexpm/elixir:1.18.2-erlang-26.2.5.7-alpine-3.18.9 AS build

RUN apk add --no-cache build-base git

WORKDIR /app

COPY mix.exs mix.lock ./
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get --only prod

COPY . .

ENV MIX_ENV=prod
RUN mix compile

# ---- RELEASE STAGE ----
FROM alpine:3.18
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

COPY --from=build /app/_build /app/_build
COPY --from=build /app/lib /app/lib
COPY --from=build /app/mix.exs /app/mix.exs
COPY --from=build /app/mix.lock /app/mix.lock

EXPOSE 4040
ENV MIX_ENV=prod
ENV PORT=4040

CMD ["elixir", "--erl", "-sname chat_app", "-S", "mix", "run", "--no-halt"]
