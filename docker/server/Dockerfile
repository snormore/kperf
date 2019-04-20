FROM golang:1.12

RUN apt-get update -qq && \
    apt-get install -y iperf3

RUN go get github.com/mattn/goreman

ADD . /app

WORKDIR /app

RUN cd httpserver && \
    go build -o /usr/local/bin/httpserver

CMD ["goreman", "-set-ports=false", "start"]