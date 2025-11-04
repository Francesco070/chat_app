# ---- BUILD STAGE ----
FROM hexpm/elixir:1.15.2-erlang-26.0-alpine AS build

RUN apk add --no-cache build-base git

WORKDIR /app

# Cache dependencies
COPY mix.exs mix.lock ./
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get

# Copy source
COPY . .

# Kompiliere den Code vollständig (sehr wichtig!)
RUN MIX_ENV=prod mix compile

# ---- RELEASE STAGE ----
FROM alpine:3.18

RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app
COPY --from=build /app ./

EXPOSE 4040
ENV MIX_ENV=prod
ENV PORT=4040

CMD ["mix", "run", "--no-halt"]
