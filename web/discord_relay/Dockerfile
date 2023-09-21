FROM golang:1.15.4-alpine as builder

ENV GOPATH=/build
ENV GOBIN=/usr/local/go/bin

WORKDIR $GOPATH/src
COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .

ARG BRANCH=HEAD
RUN CGO_ENABLED=0 GOOS=linux go build -a -o cfc_chat_relay . \
	&& cp cfc_chat_relay $GOPATH/.

CMD [ "/build/cfc_chat_relay" ]

FROM alpine:3.11.3
COPY --from=builder /build/cfc_chat_relay .

CMD [ "./cfc_chat_relay" ]
