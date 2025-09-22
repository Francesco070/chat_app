# --- Dev/Build Image ---
FROM hexpm/elixir:1.18.2-erlang-26.2.5.7-alpine-3.18.9

# Basis-Tools
RUN apk add --no-cache build-base git bash openssl ncurses-libs

WORKDIR /app

# Hex/Rebar installieren
RUN mix local.hex --force && mix local.rebar --force

# Nur Mix-Dateien kopieren, um deps cachen zu können
COPY mix.exs mix.lock ./
RUN mix deps.get || true

# Quellcode mounten wir später über docker-compose -> kein COPY hier nötig
EXPOSE 4040

# Default env
ENV MIX_ENV=dev
ENV PORT=4040

CMD ["mix", "run", "--no-halt"]
