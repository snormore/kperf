Run a suite of network performance tests between a given client/server pair using [iperf3], [ping], and [wrk].

Collected metrics include:
 - Lantecy (ms) using [ping]
 - TCP bandwidth (Mbps) using [iperf3]
 - UDP bandwidth (Mbsp), jitter (ms), and datagram loss (%) using [iperf3]
 - HTTP throughput (rps) and latency (ms) using [wrk]

For each of these we test message size in steps from a minimum (100B) to a maximum (1500B).

# Example

Run the tests locally in Docker containers:

```
script/run-server
```

In another session:

```
script/run-client
```

[iperf3]: https://iperf.fr/
[ping]: https://linux.die.net/man/8/ping
[wrk]: https://github.com/wg/wrk
