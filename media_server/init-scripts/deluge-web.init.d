#!/bin/sh
# deluge-web
# chkconfig: 345 20 80
# description: deluge-web daemon
# Web interface for torrent loading
# processname: deluge-web

NAME="deluge-web"
RUN_AS='renan'
PIDFILE='/tmp/deluge-web.pid'
DAEMON='/usr/bin/deluge-web'
OPTS=""

start() {
    echo -n "Starting daemon: $NAME"
    /sbin/start-stop-daemon --start --quiet \
                            --chuid $RUN_AS --user $RUN_AS \
                            --pidfile ${PIDFILE} --make-pidfile --background \
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
    dbpid=$(pgrep -fu $RUN_AS "/usr/bin/python /usr/bin/deluge-web")
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
