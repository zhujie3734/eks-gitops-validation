FROM alpine:3.22
RUN apk add --no-cache git git-daemon
EXPOSE 9418
ENTRYPOINT ["git", "daemon", "--reuseaddr", "--export-all", "--base-path=/git", "--listen=0.0.0.0", "--port=9418", "/git"]
