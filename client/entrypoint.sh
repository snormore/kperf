#!/usr/bin/env bash
set -eo pipefail

if [ -z ${SERVER_IP+x} ]; then
    echo "SERVER_IP is missing"
    exit 1
fi

HTTP_PORT=${HTTP_PORT:-8000}
IPERF_PORT=${IPERF_PORT:-7000}
NETPERF_PORT=${NETPERF_PORT:-6000}
MIN_MSS=${MIN_MSS:-100}
MSS_STEP=${MIN_MSS:-100}
MAX_MSS=${MAX_MSS:-1500}
TEST_DURATION=${TEST_DURATION:-10}

PING_FLAGS=" -W${TEST_DURATION}"
if [ $(uname -s) != "Darwin" ]; then
    PING_FLAGS=" -U -w${TEST_DURATION}"
fi
# PING_SIZE=$(expr ${MAX_MSS} - 8)
set -x

if [ ! -z ${PRIVATE_TESTS+x} ]; then
    # netperf
    netperf -H ${SERVER_IP} -p ${NETPERF_PORT} -l 10 -j -c -C -t omni -- -d stream -k THROUGHPUT,THROUGHPUT_UNITS,MIN_LATENCY,MAX_LATENCY,MEAN_LATENCY,RT_LATENCY,STDDEV_LATENCY,P50_LATENCY,P90_LATENCY,P99_LATENCY,LOCAL_TRANSPORT_RETRANS,REMOTE_TRANSPORT_RETRANS,TRANSPORT_MSS,LOCAL_CPU_UTIL,REMOTE_CPU_UTIL
    netperf -H ${SERVER_IP} -p ${NETPERF_PORT} -t TCP_STREAM
    netperf -H ${SERVER_IP} -p ${NETPERF_PORT} -t TCP_CRR
    netperf -H ${SERVER_IP} -p ${NETPERF_PORT} -t UDP_STREAM -- -R 1
    netperf -H ${SERVER_IP} -p ${NETPERF_PORT} -t UDP_RR -- -R 1

    # iperf3
    iperf3 -u -i0 -t${TEST_DURATION} -c ${SERVER_IP} -p${IPERF_PORT}
    iperf3 -u -R -i0 -t${TEST_DURATION} -c ${SERVER_IP} -p${IPERF_PORT}
fi

# iperf3
iperf3 -i0 -t${TEST_DURATION} -c ${SERVER_IP} -p${IPERF_PORT}
iperf3 -R -i0 -t${TEST_DURATION} -c ${SERVER_IP} -p${IPERF_PORT}

# ping
ping ${PING_FLAGS} ${SERVER_IP}

# wrk
wrk -d${TEST_DURATION}s -t1 -c10 http://${SERVER_IP}:${HTTP_PORT}
