Run a suite of network performance tests between a given client/server pair using [netperf], [iperf3], [ping], and [wrk].

## Running

### Container-to-container local

Start the server:

```
script/run-server
```

In a different terminal, start the client that runs the tests:

```
script/run-client
```

### Node-to-node

```
export SERVER_IP=<YOUR_SERVER_IP>
export CLIENT_IP=<YOUR_CLIENT_IP>
```

```
ssh root@${SERVER_IP} -- bash -c "apt-get update -qq && apt-get install -y docker.io"
ssh root@${SERVER_IP} -- docker pull snormore/kperf-server
ssh root@${SERVER_IP} -- docker run --rm -i \
    --name kperf-server \
    --net=host \
    -e "HTTP_PORT=8000" \
    -e "IPERF_PORT=7000" \
    -e "NETPERF_PORT=6000" \
    -p8000:8000 \
    -p7000:7000/tcp \
    -p7000:7000/udp \
    -p6000:6000/tcp \
    -p6000:6000/udp \
    snormore/kperf-server
```

```
ssh root@${CLIENT_IP} -- bash -c "apt-get update -qq && apt-get install -y docker.io"
ssh root@${CLIENT_IP} -- docker pull snormore/kperf-client
ssh root@${CLIENT_IP} -- docker run --rm -i \
    --name kperf-client \
    -e "SERVER_IP=${SERVER_IP}" \
    -e "HTTP_PORT=8000" \
    -e "IPERF_PORT=7000" \
    -e "NETPERF_PORT=6000" \
    -e "PRIVATE_TESTS=1" \
    snormore/kperf-client
```

[netperf]: https://hewlettpackard.github.io/netperf/
[iperf3]: https://iperf.fr/
[ping]: https://linux.die.net/man/8/ping
[wrk]: https://github.com/wg/wrk

### Kubernetes pod-to-pod

### Kubernetes pod-to-host
