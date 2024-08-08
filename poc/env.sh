PG_URI_MASTER="host=127.0.0.1 dbname=postgres user=postgres password=postgres port=5432 target_session_attrs=read-write"

PG_URI_RO="host=127.0.0.1,127.0.0.1,127.0.0.1 dbname=clickup user=app1_read password=app1_read port=5433,5434,5435"
PG_URI_RO_POOL="host=127.0.0.1,127.0.0.1 dbname=app1_read user=app1_read password=app1_read port=6432,6433"
PG_URI_RO_POOL_HA="host=127.0.0.1 dbname=app1_read user=app1_read password=app1_read port=7432"

PG_URI_RW="host=127.0.0.1 dbname=clickup user=app1_write password=app1_write port=5432 target_session_attrs=read-write"
PG_URI_RW_POOL="host=127.0.0.1,127.0.0.1 dbname=app1_write user=app1_write password=app1_write port=6432,6433 target_session_attrs=read-write"

PG_URI_PGCAT_ADMIN="host=127.0.0.1,127.0.0.1 dbname=pgcat user=pgcat password=pgcat port=6432,6433"
