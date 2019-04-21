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

ssh root@${SERVER_IP} -- apt-get update -qq && apt-get install docker.io
ssh root@${SERVER_IP} -- docker pull snormore/perf-server
ssh root@${SERVER_IP} -- docker run --rm -i --name perf-server -e "HTTP_PORT=8000" -e "IPERF_PORT=7000" -p8000:8000 -p7000:7000 snormore/perf-server

ssh root@${CLIENT_IP} -- apt-get update -qq && apt-get install docker.io
ssh root@${CLIENT_IP} -- docker pull snormore/perf-client
ssh root@${CLIENT_IP} -- docker run --rm -i --name perf-client -e "SERVER_IP=${SERVER_IP}" -e "HTTP_PORT=8000" -e "IPERF_PORT=7000" snormore/perf-client

[netperf]: https://hewlettpackard.github.io/netperf/
[iperf3]: https://iperf.fr/
[ping]: https://linux.die.net/man/8/ping
[wrk]: https://github.com/wg/wrk

### Kubernetes pod-to-pod

### Kubernetes pod-to-host
