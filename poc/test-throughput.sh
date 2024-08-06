#!/usr/bin/env bash

script_name=$(basename $0 .sh)

function run_pgbench () {
    p=$1
    c=$2
    M=$3
    T=$4
    b=$5
    tag="$script_name.$b.p$p.M$M.T$T.c$c"
    log="result.$tag.log"
    cmd="pgbench -n -b $b -c $c -M $M -T $T -p $p"
    if ls $log &>/dev/null; then
        echo "*** $tag WARNING $log already present, skipping test."
        return
    fi
    echo "*** $tag running { $cmd &> $log }"
    if ! $cmd &> $log; then
        echo "*** $tag ERROR failed to run { $cmd &> $log }"
    fi
}

for c in `seq 2 2 10`; do
    for T in 12; do
        for M in simple extended; do
            for p in 5432 6432; do
                for b in select-only tpcb-like; do
                    run_pgbench $p $c $M $T $b
                done
            done
        done
    done
done
