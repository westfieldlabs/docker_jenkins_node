#!/bin/bash

#start postgres
rm -rf /var/lib/pgsql/9.3/data/postmaster.pid
runuser -l postgres --session-command "/usr/pgsql-9.3/bin/pg_ctl -D /var/lib/pgsql/9.3/data -l logfile start"

#start redis 
redis-server --daemonize yes

# Start SSH
/usr/sbin/sshd -D