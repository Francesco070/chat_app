FROM hexpm/elixir:1.18.2-erlang-26.2.5.7-alpine-3.18.9

RUN apk add --no-cache build-base git bash openssl ncurses-libs

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get || true

EXPOSE 4040

ENV MIX_ENV=dev
ENV PORT=4040

CMD ["mix", "run", "--no-halt"]
