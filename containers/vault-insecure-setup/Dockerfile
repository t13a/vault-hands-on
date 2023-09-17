FROM alpine

RUN apk add --no-cache bash curl jq

COPY rootfs /

ENTRYPOINT ["vault-insecure-setup"]

CMD ["main"]
