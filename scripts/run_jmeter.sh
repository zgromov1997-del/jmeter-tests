#!/bin/bash
set -e

TEST_PLAN="${1:-Test_Plan1somnenie.jmx}"
THREADS="${2:-1}"
RAMPUP="${3:-30}"
DURATION="${4:-60}"
RAW_URL="${5:-http://localhost:3000}"
THROUGHPUT="${6:-1}"

WORK_DIR="$(pwd)"
JMETER_BIN="/home/egromov/apache-jmeter-5.6.3/bin/jmeter"

if [[ "$RAW_URL" == http://* || "$RAW_URL" == https://* ]]; then
    PROTOCOL="${RAW_URL%%://*}"
    HOST_PORT_PATH="${RAW_URL#*://}"
else
    PROTOCOL="http"
    HOST_PORT_PATH="$RAW_URL"
fi

HOST_PORT="${HOST_PORT_PATH%%/*}"

if [[ "$HOST_PORT" == *:* ]]; then
    HOST="${HOST_PORT%%:*}"
    PORT="${HOST_PORT##*:}"
else
    HOST="$HOST_PORT"
    if [[ "$PROTOCOL" == "https" ]]; then
        PORT="443"
    else
        PORT="80"
    fi
fi

echo "TEST_PLAN=$TEST_PLAN"
echo "THREADS=$THREADS"
echo "RAMPUP=$RAMPUP"
echo "DURATION=$DURATION"
echo "RAW_URL=$RAW_URL"
echo "PROTOCOL=$PROTOCOL"
echo "HOST=$HOST"
echo "PORT=$PORT"
echo "THROUGHPUT=$THROUGHPUT"

mkdir -p results
rm -rf results/*

"$JMETER_BIN" -n \
    -t "$WORK_DIR/test-plans/$TEST_PLAN" \
    -q "$WORK_DIR/properties/test.properties" \
    -Jthreads="$THREADS" \
    -JrampUp="$RAMPUP" \
    -Jduration="$DURATION" \
    -Jprotocol="$PROTOCOL" \
    -Jurl="$HOST" \
    -Jport="$PORT" \
    -Jthroughput="$THROUGHPUT" \
    -l "$WORK_DIR/results/results.jtl" \
    -e \
    -o "$WORK_DIR/results/html-report"