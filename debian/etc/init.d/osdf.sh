#!/bin/bash
#
# /etc/init.d/osdf -- startup script for OSDF
#
# Written by Victor Felix for OSDF <victor73@gmail.com>.
#
### BEGIN INIT INFO
# Provides:          osdf
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts osdf
# Description:       Starts osdf using start-stop-daemon
### END INIT INFO

set -e

PATH=/bin:/usr/bin:/sbin:/usr/sbin
NAME=osdf
DESC="OSDF Server"
DEFAULT=/etc/default/$NAME

if [ `id -u` -ne 0 ]; then
    echo "You need root privileges to run this script"
    exit 1
fi

. /lib/lsb/init-functions

if [ -r /etc/default/rcS ]; then
    . /etc/default/rcS
fi


# The following variables can be overwritten in $DEFAULT

# Run OSDF as this user ID and group ID
OSDF_USER=osdf
OSDF_GROUP=osdf

# Directory where the OSDF binary distribution resides
NODE_HOME=/usr/share/$NAME

# OSDF log directory
LOG_DIR=/var/log/$NAME

# OSDF data directory
DATA_DIR=/var/lib/$NAME

# OSDF work directory
WORK_DIR=/tmp/$NAME

# OSDF configuration directory
CONF_DIR=/etc/$NAME

# OSDF configuration file
CONF_FILE=$CONF_DIR/config.ini

# End of the variables that can be overwritten in $DEFAULT

# overwrite settings from default file
if [ -f "$DEFAULT" ]; then
    . "$DEFAULT"
fi

# Define other required variables
PID_FILE=/var/run/$NAME.pid
DAEMON=/usr/bin/node
DAEMON_OPTS=""

# Check DAEMON exists
test -x $DAEMON || exit 0

case "$1" in
  start)
    log_daemon_msg "Starting $DESC"
    
    if start-stop-daemon --test --start --pidfile "$PID_FILE" \
        --user "$OSDF_USER" --exec "$NODE" \
        >/dev/null; then
        
        # Prepare environment
        mkdir -p "$LOG_DIR" "$DATA_DIR" "$WORK_DIR" && chown "$OSDF_USER":"$OSDF_GROUP" "$LOG_DIR" "$DATA_DIR" "$WORK_DIR"
        touch "$PID_FILE" && chown "$OSDF_USER":"$OSDF_GROUP" "$PID_FILE"
        ulimit -n 65535

        # Start Daemon
        start-stop-daemon --start --background --chuid "$OSDF_USER" --pidfile "$PID_FILE" \
            --user "$OSDF_USER" --exec /bin/bash -- -c "$DAEMON $DAEMON_OPTS"

        sleep 1
        if start-stop-daemon --test --start --pidfile "$PID_FILE" \
            --user "$OSDF_USER" --exec "$NODE" \
            >/dev/null; then
            if [ -f "$PID_FILE" ]; then
                rm -f "$PID_FILE"
            fi
            log_end_msg 1
        else
            log_end_msg 0
        fi
        
    else
        log_progress_msg "(already running)"
        log_end_msg 0
    fi
    ;;
  stop)
    log_daemon_msg "Stopping $DESC"

    set +e
    if [ -f "$PID_FILE" ]; then 
        start-stop-daemon --stop --pidfile "$PID_FILE" \
            --user "$OSDF_USER" \
            --retry=TERM/20/KILL/5 >/dev/null
        if [ $? -eq 1 ]; then
            log_progress_msg "$DESC is not running but pid file exists, cleaning up"
        elif [ $? -eq 3 ]; then
            PID="`cat $PID_FILE`"
            log_failure_msg "Failed to stop $DESC (pid $PID)"
            exit 1
        fi
        rm -f "$PID_FILE"
    else
        log_progress_msg "(not running)"
    fi
    log_end_msg 0
    set -e
    ;;
  status)
    set +e
    start-stop-daemon --test --start --pidfile "$PID_FILE" \
        --user "$OSDF_USER" --exec "$NODE" \
        >/dev/null 2>&1
    if [ "$?" = "0" ]; then

        if [ -f "$PID_FILE" ]; then
            log_success_msg "$DESC is not running, but pid file exists."
            exit 1
        else
            log_success_msg "$DESC is not running."
            exit 3
        fi
    else
        log_success_msg "$DESC is running with pid `cat $PID_FILE`"
    fi
    set -e
    ;;
  restart|force-reload)
    if [ -f "$PID_FILE" ]; then
        $0 stop
        sleep 1
    fi
    $0 start
    ;;
  *)
    log_success_msg "Usage: $0 {start|stop|restart|force-reload|status}"
    exit 1
    ;;
esac

exit 0
