#!/usr/bin/env bash
set -eEo pipefail

# load PG_URI* env vars from env.sh
{ set -a && source $(dirname -- $0)/env.sh && set +a; } || return

main () {
    workmode=$1
    case $workmode in
        liveness)
            liveness
            ;;
        tps)
            tps
            ;;
        *)
            echo "Usage: $0 ( liveness | tps )"
    esac
}

tps () {
    # Run simple bench on tested endpoints and show TPS value 
    delay=3.0
    while true; do
        echo -n "$(date -u) read-only: "
        check_tps "$PG_URI_RO_POOL" select-only 3
        echo -n ", read-write: "
        check_tps "$PG_URI_RW_POOL" simple-update 1
        echo "."
        sleep $delay
    done
}

liveness () {
    # Show endpoint status and response time
    i=0
    delay=0.75
    show_dbs_every=10
    show_pools_every=60
    while true; do
        i=$((i + 1))
        echo -n "$(date -u) read-only: "
        check_liveness "$PG_URI_RO_POOL" "select 1"
        echo -n ", read-only HA: "
        check_liveness "$PG_URI_RO_POOL_HA" "select 1"
        echo -n ", read-write: "
        check_liveness "$PG_URI_RW_POOL" "update pgbench_branches set filler='$0' where bid = 1"
        echo -n ", pgcat-admin: "
        check_liveness "$PG_URI_PGCAT_ADMIN" "show version"
        echo "."
        # from time to time, show pooler stats
        if [ $(( $i % $show_dbs_every )) -eq 0 ]; then
            psql -X "$PG_URI_PGCAT_ADMIN" -c "show databases" 2>/dev/null | cat || true
        fi
        if [ $(( $i % $show_pools_every )) -eq 0 ]; then
            psql -X "$PG_URI_PGCAT_ADMIN" -c "show pools" 2>/dev/null | cat || true
        fi
        sleep $delay
    done
}

check_liveness () {
    uri="$1"
    query="$2"
    time0=$(date +%s%3N)  # ms
    if timeout 10 psql "$uri" -XqAtc "$query" &>/dev/null; then
        status=OK
    else
        status=FAIL
    fi
    time1=$(date +%s%3N)  # ms
    timedelta=$((time1 - time0))
    echo -n "${status} (${timedelta} ms)"
}

check_tps () {
    uri="$1"
    builtin="${2:-select-only}"
    scale="${3:-10}"
    time0=$(date +%s%3N)  # ms
    tmpfile=$(mktemp)
    if timeout $((scale * 2)) pgbench "$uri" -n -b "$builtin" -c "$scale" -T "$scale" &> "$tmpfile"; then
        status=OK
        tps=$(awk '/^tps/{print $3; exit}' < "$tmpfile" | cut -d. -f1)
    else
        status=FAIL
        tps=0.0
    fi
    time1=$(date +%s%3N)  # ms
    timedelta=$((time1 - time0))
    rm -f "$tmpfile"
    echo -n "$status ($tps tps, $timedelta ms)"
}

main "$@"
