psql -h 172.18.0.2 -U postgres -p 5432 -d cm6 -c "DROP SCHEMA public CASCADE;"
psql -h 172.18.0.2 -U postgres -p 5432 -d cm6 -c "VACUUM FULL VERBOSE ANALYZE;"
psql -h 172.18.0.2 -U postgres -p 5432 -d cm6 -c "CREATE SCHEMA public;"
