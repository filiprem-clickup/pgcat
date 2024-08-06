# Constant
DBNAME=clickup

echo "*** Listing environment variables (except passwords) ***"
env | grep -v -i password

echo "*** Allowing replication connections in $PGDATA/pg_hba.conf ***"
{
    echo "# Allow replication connections (added by $0)"
    echo "host replication all all md5"
} >> $PGDATA/pg_hba.conf

echo "*** Creating application database ***"
psql -c "CREATE DATABASE $DBNAME"

echo "*** Populating application database ***"
pgbench -i -q -s 100 $DBNAME

echo "*** Creating application users ***"
psql -c "CREATE USER app1_read PASSWORD 'app1_read'"
psql -c "CREATE USER app1_write PASSWORD 'app1_write'"

echo "*** Granting access to application users ***"
psql $DBNAME -c "GRANT USAGE ON SCHEMA public TO app1_read, app1_write"
psql $DBNAME -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO app1_read, app1_write"
psql $DBNAME -c "GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA public TO app1_write"
