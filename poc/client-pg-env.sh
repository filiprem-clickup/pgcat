#!/usr/bin/env bash

# Note: do not set PGPORT here, it is used to distinguish direct/pooled connections

PGHOST=127.0.0.1
PGDATABASE=clickup
PGUSER=app1_write
PGPASSWORD=app1_write

export PGHOST PGDATABASE PGUSER PGPASSWORD
