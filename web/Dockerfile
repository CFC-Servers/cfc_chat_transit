FROM golang:1.15.4-alpine as builder

ENV GOPATH=/build
ENV GOBIN=/usr/local/go/bin
ENV GO111MODULE=on

WORKDIR $GOPATH/src
COPY . .

ARG BRANCH=HEAD
RUN go mod init cfc_chat_relay\
    && go get github.com/gorilla/websocket@$BRANCH \
    && go get github.com/bwmarrin/discordgo@$BRANCH \
	&& go list -m all \
	&& go fmt \
	&& CGO_ENABLED=0 GOOS=linux go build -a -o cfc_chat_relay . \
	&& cp cfc_chat_relay $GOPATH/.

CMD [ "/build/cfc_chat_relay" ]

FROM alpine:3.11.3
COPY --from=builder /build/cfc_chat_relay .

CMD [ "./cfc_chat_relay" ]
