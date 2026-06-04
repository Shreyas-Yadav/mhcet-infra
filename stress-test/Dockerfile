FROM alpine:3.20
RUN apk add --no-cache bash curl
COPY stress.sh /stress.sh
RUN chmod +x /stress.sh
ENTRYPOINT ["/stress.sh"]
