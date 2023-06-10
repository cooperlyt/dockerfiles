#!/bin/bash
set -e

source /etc/profile
touch /tmp/start.log
chown mysql: /tmp/start.log
chown -R mysql: /home/mysql/canal-server
host=`hostname -i`

# waitterm
#   wait TERM/INT signal.
#   see: http://veithen.github.io/2014/11/16/sigterm-propagation.html
waitterm() {
        local PID
        # any process to block
        tail -f /dev/null &
        PID="$!"
        # setup trap, could do nothing, or just kill the blocker
        trap "kill -TERM ${PID}" TERM INT
        # wait for signal, ignore wait exit code
        wait "${PID}" || true
        # clear trap
        trap - TERM INT
        # wait blocker, ignore blocker exit code
        wait "${PID}" 2>/dev/null || true
}

# waittermpid "${PIDFILE}".
#   monitor process by pidfile && wait TERM/INT signal.
#   if the process disappeared, return 1, means exit with ERROR.
#   if TERM or INT signal received, return 0, means OK to exit.
waittermpid() {
        local PIDFILE PID do_run error
        PIDFILE="${1?}"
        do_run=true
        error=0
        trap "do_run=false" TERM INT
        while "${do_run}" ; do
                PID="$(cat "${PIDFILE}")"
                if ! ps -p "${PID}" >/dev/null 2>&1 ; then
                        do_run=false
                        error=1
                else
                        sleep 1
                fi
        done
        trap - TERM INT
        return "${error}"
}


function checkStart() {
    local name=$1
    local cmd=$2
    local timeout=$3
    cost=5
    while [ $timeout -gt 0 ]; do
        ST=`eval $cmd`
        echo "check result: $ST"
        if [ "$ST" == "0" ]; then
            sleep 1
            let timeout=timeout-1
            let cost=cost+1
        elif [ "$ST" == "" ]; then
            sleep 1
            let timeout=timeout-1
            let cost=cost+1
        else
            break
        fi
    done
    echo "start $name successful"
}


function start_canal() {
    echo "start canal ..."
    managerAddress=`perl -le 'print $ENV{"canal.admin.manager"}'`
    if [ ! -z "$managerAddress" ] ; then
        # canal_local.properties mode
        adminPort=`perl -le 'print $ENV{"canal.admin.port"}'`
        if [ -z "$adminPort" ] ; then
            adminPort=11110
        fi

        su mysql -c 'cd /home/mysql/canal-server/bin/ && sh restart.sh local 1>>/tmp/start.log 2>&1'
        sleep 5
        #check start
        checkStart "canal" "nc 127.0.0.1 $adminPort -w 1 -z | wc -l" 30
    else
        metricsPort=`perl -le 'print $ENV{"canal.metrics.pull.port"}'`
        if [ -z "$metricsPort" ] ; then
            metricsPort=11112
        fi

        destination=`perl -le 'print $ENV{"canal.destinations"}'`
        if [[ "$destination" =~ ',' ]]; then
            echo "multi destination:$destination is not support"
            exit 1;
        else
            if [ "$destination" != "" ] && [ "$destination" != "example" ] ; then
                if [ -d /home/mysql/canal-server/conf/example ]; then
                    mv /home/mysql/canal-server/conf/example /home/mysql/canal-server/conf/$destination
                fi
            fi 
        fi



        su mysql -c 'cd /home/mysql/canal-server/bin/ && sh restart.sh 1>>/tmp/start.log 2>&1'

    
        sleep 5
        #check start
        checkStart "canal" "nc -v -z -w 1 127.0.0.1 11112 &> /dev/null && echo 'Port is Open' || echo ''" 30
    fi  
}

function stop_canal() {
    echo "stop canal"
    su mysql -c 'cd /home/mysql/canal-server/bin/ && sh stop.sh 1>>/tmp/start.log 2>&1'
    echo "stop canal successful ..."
}

function start_exporter() {
    su mysql -c 'cd /home/mysql/node_exporter && ./node_exporter 1>>/tmp/start.log 2>&1 &'
}

function stop_exporter() {
    su mysql -c 'killall node_exporter'
}

function start_mariadb(){
    echo "start mariadb"
    su mysql -c "sh /usr/local/bin/docker-entrypoint.sh $@ 1>>/tmp/start.log 2>&1"
    echo "start mariadb successful ..."

}

echo "==> START ..."

start_mariadb
# start_exporter
start_canal

echo "==> START SUCCESSFUL ..."

tail -f /dev/null &
# wait TERM signal
waitterm

echo "==> STOP"

stop_canal
# stop_exporter

echo "==> STOP SUCCESSFUL ..."
