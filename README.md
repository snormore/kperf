Run a suite of network performance tests between a given client/server pair using [iperf3], [ping], and [wrk].

Collected metrics include:
 - Lantecy (ms) using [ping]
 - TCP bandwidth (Mbps) using [iperf3]
 - UDP bandwidth (Mbsp), jitter (ms), and datagram loss (%) using [iperf3]
 - HTTP throughput (rps) and latency (ms) using [wrk]

For each of these we test message size in steps from 10 to 10000 bytes.

# Example

The following commands assume you are running `iperf3 -s -p3000` and `docker run --rm -p80:80 snormore/hello` on the destination server.

```
perf -client <src_ip> -server <dst_ip>
```

[iperf3]: https://iperf.fr/
[ping]: https://linux.die.net/man/8/ping
[wrk]: https://github.com/wg/wrk
