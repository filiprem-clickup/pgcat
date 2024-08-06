# Primary host is known and fixed at the time of deployment.
PRIMARY_HOST=db1

echo "*** Listing environment variables (except passwords) ***"
env | grep -v -i password

echo "*** Stopping postgres ***"
pg_ctl stop -m fast 

echo "*** Removing contents of $PGDATA ***"
rm -rf "$PGDATA"/{*,.*}

echo "*** Creating replication slot for $HOSTNAME ***"
psql -d "host=$PRIMARY_HOST port=5432 user=$POSTGRES_USER password=$POSTGRES_PASSWORD" -c "SELECT
pg_create_physical_replication_slot (slot_name := '$HOSTNAME', immediately_reserve := false) WHERE
NOT EXISTS (SELECT FROM pg_replication_slots WHERE slot_name = '$HOSTNAME')"

echo "*** Running pg_basebackup -R ***"
# Note: slot name relies on hostname setting, make sure your deployment includes hostnames.
pg_basebackup -D "$PGDATA" -R -X stream -c fast -P -S "$HOSTNAME" -v -d "host=$PRIMARY_HOST port=5432 user=$POSTGRES_USER password=$POSTGRES_PASSWORD" -w

echo "*** Starting postgres ***"
pg_ctl start -o "-c config_file=/postgresql.conf"

echo "*** Sleeping 1 second so the replica can start syncing ***"
sleep 1
