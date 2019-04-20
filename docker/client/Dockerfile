FROM golang:1.12

RUN apt-get update -qq && \
    apt-get install -y iperf3

RUN WRK_VERSION=$(curl -L https://github.com/wg/wrk/raw/master/CHANGES 2>/dev/null | \
                  egrep '^wrk' | head -n 1 | awk '{print $2}') && \ 
    echo $WRK_VERSION  && \
    mkdir /opt/wrk && \
    cd /opt/wrk && \
    curl -L https://github.com/wg/wrk/archive/$WRK_VERSION.tar.gz | \
    tar zx --strip 1 && \
    make && \
    cp wrk /usr/local/bin/

ADD . /app

WORKDIR /app

RUN make build-client-package

# ENTRYPOINT ["/app/bin/perf"]

CMD ["/app/docker/client/entrypoint.sh"]