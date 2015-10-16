#!/bin/sh
### BEGIN INIT INFO
# Provides: calibre-server
# Required-Start: $local_fs $network
# Required-Stop: $local_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: calibre-server
### END INIT INFO

RUN_AS='renan'
PIDFILE='/tmp/calibre-server.pid'
EXECUTABLE='/opt/calibre/calibre-server'
OPTS="--with-library /home/renan/Copy/Library/Computing \
      --url-prefix /books \
      --port=4366
      --pidfile=$PIDFILE
      --daemonize
"

start() {
    # matching interpreted daemons is so frikin tricky...
    echo 'Starting calibre server...'
    [ -f $PIDFILE ] && { echo "pidfile $PIDFILE exists. remove it first" && exit 1 ;}
    /sbin/start-stop-daemon --start --chuid $RUN_AS \
                            --user $RUN_AS \
                            --pidfile ${PIDFILE} \
                            --exec $EXECUTABLE -- $OPTS
    echo 'done.'
}

stop() {
    if [ -f $PIDFILE ]; then
        echo 'Stopping calibre server...'
        /bin/kill $(cat $PIDFILE) && rm $PIDFILE && echo 'done.'
    else
        echo 'Nothing to be done.'
    fi
}

status() {
    dbpid=$(pgrep -fu $RUN_AS 'calibre-server --with-library')
    if [ -z "$dbpid" ]; then
        echo "calibre-server for user $RUN_AS: not running."
    else
        echo "calibre-server for user $RUN_AS: running (pid $dbpid)"
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
