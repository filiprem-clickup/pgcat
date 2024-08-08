#!/usr/bin/env bash

LIVENESS_TIMEOUT=10  # seconds

main () {
    { set -a && source $(dirname -- $0)/env.sh && set +a; } || return
    i=0
    delay=1.0
    show_dbs_every=10
    show_pools_every=60
    while true; do
        let i++
        echo -n "$(date -u) $i readonly: "
        mydbtest "$PG_URI_RO_POOL"
        echo -n ", read/write: "
        mydbtest "$PG_URI_RW_POOL"
        echo "."
        # from time to time, show pooler stats
        if [ $(( $i % $show_dbs_every )) -eq 0 ]; then
            psql -X "$PG_URI_PGCAT_ADMIN" -c "show databases" | cat
        fi
        if [ $(( $i % $show_pools_every )) -eq 0 ]; then
            psql -X "$PG_URI_PGCAT_ADMIN" -c "show pools" | cat
        fi
        sleep $delay
    done
}

mydbtest () {
    time0=$(date +%s%3N)  # ms
    if timeout ${LIVENESS_TIMEOUT-10} psql -XqAtc ";" "$@" &>/dev/null; then
        status=OK
    else
        status=FAIL
    fi
    time1=$(date +%s%3N)  # ms
    timedelta=$((time1 - time0))
    echo -n "${status} (${timedelta} ms)"
}

main "$@"
