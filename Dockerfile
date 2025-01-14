FROM golang:latest AS go

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

ADD . /src/honeytrap

ARG LDFLAGS=""

WORKDIR /src/honeytrap
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -tags="" -ldflags="$(go run scripts/gen-ldflags.go)" -o /go/bin/app .

FROM alpine
MAINTAINER  Remco Verhoef <remco.verhoef@dutchsec.com>

RUN apk --update upgrade && apk add curl ca-certificates && rm -rf /var/cache/apk/*
RUN apk add ca-certificates && update-ca-certificates

RUN mkdir /config /data

RUN curl -s -o /config/config.toml https://raw.githubusercontent.com/yevonnaelandrew/honeytrap/master/config/config.toml
COPY --from=go /go/bin/app /honeytrap/honeytrap

ENTRYPOINT ["/honeytrap/honeytrap", "--config", "/config/config.toml", "--data", "/data/"]

EXPOSE 2222 5900 53
