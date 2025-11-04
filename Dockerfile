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
    mkdir -p /app/tmp && \
    chown -R chat:chat /app /app/tmp

USER chat

# Set environment variables
ENV PORT=4040
ENV MIX_ENV=prod
ENV HOME=/app
ENV RELEASE_TMP=/app/tmp
ENV TMPDIR=/app/tmp

EXPOSE 4040

CMD ["/app/bin/chat_app", "start"]
