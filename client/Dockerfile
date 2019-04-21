FROM golang:1.12

# Install iperf3
RUN apt-get update -qq && \
    apt-get install -y iperf3

# Install wrk
RUN WRK_VERSION=$(curl -L https://github.com/wg/wrk/raw/master/CHANGES 2>/dev/null | \
                  egrep '^wrk' | head -n 1 | awk '{print $2}') && \ 
    echo $WRK_VERSION  && \
    mkdir /opt/wrk && \
    cd /opt/wrk && \
    curl -L https://github.com/wg/wrk/archive/$WRK_VERSION.tar.gz | \
    tar zx --strip 1 && \
    make && \
    cp wrk /usr/local/bin/

# Install netperf
RUN curl -LO https://github.com/HewlettPackard/netperf/archive/netperf-2.7.0.tar.gz \
    && tar -xzf netperf-2.7.0.tar.gz \
    && mv netperf-netperf-2.7.0/ netperf-2.7.0
RUN cd netperf-2.7.0 && ./configure \
    && make && make install

# Install client.
ADD . /app
WORKDIR /app
RUN make

# ENTRYPOINT ["/app/bin/perf"]

CMD ["/app/entrypoint.sh"]