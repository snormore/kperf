FROM golang:1.12

# Install iperf3
RUN apt-get update -qq && \
    apt-get install -y iperf3

# Install netperf
RUN curl -LO https://github.com/HewlettPackard/netperf/archive/netperf-2.7.0.tar.gz \
    && tar -xzf netperf-2.7.0.tar.gz \
    && mv netperf-netperf-2.7.0/ netperf-2.7.0
RUN cd netperf-2.7.0 && ./configure \
    && make && make install

# Install goreman
RUN go get github.com/mattn/goreman

# Install httpserver
ADD . /app
WORKDIR /app
RUN cd httpserver && \
    go build -o /usr/local/bin/httpserver

EXPOSE 8000/tcp
EXPOSE 7000/tcp
EXPOSE 7000/udp
EXPOSE 6000/tcp
EXPOSE 6000/udp

CMD ["goreman", "--set-ports=false", "start"]