ARG BUILD_SPEC="build.amd64"
# Builder
FROM golang:1.22

# Optional corporate CA (BuildKit secret: --secret id=corp_ca,src=paypal-crypto-root-ca.crt)
RUN --mount=type=secret,id=corp_ca,required=false,target=/tmp/corp-ca.crt \
    if [ -f /tmp/corp-ca.crt ]; then \
      cp /tmp/corp-ca.crt /usr/local/share/ca-certificates/corp-ca.crt && update-ca-certificates; \
    fi

ARG GOPROXY=direct
ARG GOSUMDB=off
ENV GOPROXY=${GOPROXY}
ENV GOSUMDB=${GOSUMDB}

WORKDIR /go/src/github.com/paypal/load-watcher
COPY . .

RUN make ${BUILD_SPEC}

# Runtime
FROM alpine:3.12

COPY --from=0 /go/src/github.com/paypal/load-watcher/bin/load-watcher /bin/load-watcher

CMD ["/bin/load-watcher"]
