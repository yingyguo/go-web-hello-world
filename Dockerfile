
FROM golang:1.12.7 as builder
WORKDIR /go/src/app

COPY main.go .
RUN CGO_ENABLED=0 GOOS=linux go build -o go-web-hello-world .


FROM scratch
COPY --from=builder /go/src/app/go-web-hello-world /

CMD ["/go-web-hello-world"]
