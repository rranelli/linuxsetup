#!/bin/sh
### BEGIN INIT INFO
# Provides: calibre-server
# Required-Start: $local_fs $network
# Required-Stop: $local_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: calibre-server
### END INIT INFO

NAME="calibre-server"
RUN_AS='renan'
PIDFILE='/tmp/calibre-server.pid'
DAEMON='/opt/calibre/calibre-server'
OPTS="--with-library /home/renan/Copy/Library/Computing \
      --url-prefix /books \
      --port=4366
      --pidfile=$PIDFILE
      --daemonize
"

start() {
    echo -n "Starting daemon: $NAME"
    /sbin/start-stop-daemon --start --quiet \
                            --chuid $RUN_AS --user $RUN_AS \
                            --pidfile ${PIDFILE} \
                            --startas $DAEMON -- $OPTS
    echo '.'
}

stop() {
    echo -n "Stopping daemon: $NAME"
    /sbin/start-stop-daemon --stop --quiet --oknodo \
                            --user $RUN_AS \
                            --pidfile ${PIDFILE} \
                            --startas $DAEMON -- $OPTS
    echo '.'
}

status() {
    dbpid=$(pgrep -fu $RUN_AS 'calibre-server --with-library')
    if [ -z "$dbpid" ]; then
        echo "$NAME for user $RUN_AS: not running."
    else
        echo "$NAME for user $RUN_AS: running (pid $dbpid)"
    fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart|reload|force-reload)
        stop
        start
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: /etc/init.d/calibre-server {start|stop|reload|force-reload|restart|status}"
        exit 1
esac

exit 0
