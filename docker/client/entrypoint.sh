#!/usr/bin/env bash
set -eo pipefail

if [ -z ${SERVER_IP+x} ]; then
    echo "SERVER_IP is missing"
    exit 1
fi

HTTP_PORT=${HTTP_PORT:-8000}
IPERF_PORT=${IPERF_PORT:-5000}
MIN_MSS=${MIN_MSS:-100}
MSS_STEP=${MIN_MSS:-100}
MAX_MSS=${MAX_MSS:-1500}
TEST_DURATION=${TEST_DURATION:-10}

set -x
ping -U -w${TEST_DURATION} -s$(expr ${MAX_MSS} - 8) ${SERVER_IP}
iperf3 -i1 -t${TEST_DURATION} -c ${SERVER_IP} -p${IPERF_PORT} -M${MAX_MSS}
iperf3 -R -i1 -t${TEST_DURATION} -c ${SERVER_IP} -p${IPERF_PORT} -M${MAX_MSS}
iperf3 -u -i1 -t${TEST_DURATION} -c ${SERVER_IP} -p${IPERF_PORT} -M${MAX_MSS}
wrk -d${TEST_DURATION}s -t1 -c10 http://${SERVER_IP}:${HTTP_PORT}
