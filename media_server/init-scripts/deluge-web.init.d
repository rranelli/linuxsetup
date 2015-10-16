#!/bin/sh
# deluge-web
# chkconfig: 345 20 80
# description: deluge-web daemon
# Web interface for torrent loading
# processname: deluge-web

RUN_AS='renan'
PIDFILE='/var/run/deluge-web.pid'
EXECUTABLE='/usr/bin/deluge-web'
OPTS="-f"

start() {
    # matching interpreted daemons is so frikin tricky...
    echo 'Starting deluge-web ...'
    /sbin/start-stop-daemon --start --chuid $RUN_AS \
                            --user $RUN_AS \
                            --pidfile ${PIDFILE} \
                            --exec $EXECUTABLE -- $OPTS
    echo 'done.'
}

stop() {
    if [ -f $PIDFILE ]; then
        echo 'Stopping deluge-web ...'
        /bin/kill $(cat $PIDFILE) && rm $PIDFILE && echo 'done.'
    else
        echo 'Nothing to be done.'
    fi
}

status() {
    dbpid=$(pgrep -fu $RUN_AS 'deluge-web')
    if [ -z "$dbpid" ]; then
        echo "deluge-web for user $RUN_AS: not running."
    else
        echo "deluge-web for user $RUN_AS: running (pid $dbpid)"
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
