#!/bin/bash
#start postgres
runuser -l postgres --session-command "/usr/pgsql-9.3/bin/pg_ctl init"
runuser -l postgres --session-command "/usr/pgsql-9.3/bin/pg_ctl -D /var/lib/pgsql/9.3/data -l logfile start"
#config db encoding
sleep 15
psql -U postgres -f /opt/utf8.sql