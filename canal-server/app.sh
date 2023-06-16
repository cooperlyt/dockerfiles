#!/bin/bash
set -eo pipefail
shopt -s nullglob

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
        echo "check $name result: $ST"
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
    echo "start canal server..."
    managerAddress=`perl -le 'print $ENV{"canal.admin.manager"}'`
    if [ ! -z "$managerAddress" ] ; then
        # canal_local.properties mode
        adminPort=`perl -le 'print $ENV{"canal.admin.port"}'`
        if [ -z "$adminPort" ] ; then
            adminPort=11110
        fi
        bash /home/mysql/canal-server/bin/restart.sh local 1>>/tmp/start.log 2>&1
        sleep 5
        #check start
        checkStart "canal" "nc 127.0.0.1 $adminPort -w 1 -z | wc -l" 30
    else
        metricsPort=`perl -le 'print $ENV{"canal.metrics.pull.port"}'`
        if [ -z "$metricsPort" ] ; then
            metricsPort=11112
        fi

        destination=`perl -le 'print $ENV{"canal.destinations"}'`
        destinationExpr=`perl -le 'print $ENV{"canal.destinations.expr"}'`
        multistream=`perl -le 'print $ENV{"canal.instance.multi.stream.on"}'`


        if [[ "$destination" =~ ',' ]] || [[ -n "$destinationExpr" ]]; then
            if [[ "$multistream" = 'true' ]] ; then
                if [[ -n "$destinationExpr" ]] ; then
                    splitDestinations '1' $destinationExpr
                else
                    splitDestinations '2' $destination
                fi
            else
                echo "multi destination is not support, destinationExpr:$destinationExpr, destinations:$destination"
                exit 1;
            fi
        else
            if [ "$destination" != "" ] && [ "$destination" != "example" ] ; then
                if [ -d /home/mysql/canal-server/conf/example ]; then
                    mv /home/mysql/canal-server/conf/example /home/mysql/canal-server/conf/$destination
                fi
            fi 
        fi

        bash /home/mysql/canal-server/bin/stop.sh 1>>/tmp/start.log 2>&1
        bash /home/mysql/canal-server/bin/startup.sh 1>>/tmp/start.log 2>&1

        sleep 5
        #check start
        checkStart "canal-server" "nc -v -z -w 1 127.0.0.1 11112 &> /dev/null && echo 'Port is Open' || echo ''" 30
    fi  
}

function splitDestinations() {
    holdExample="false"
    prefix=''
    array=()

    if [[  "$1" == '1' ]] ; then
        echo "split destinations expr "$2
        prefix=$(echo $2 | sed 's/{.*//')
        num=$(echo $2 | sed 's/.*{//;s/}//;s/-/ /')
        array=($(seq $num))
    else
        echo "split destinations "$2
        array=(${2//,/ })
    fi

    for var in ${array[@]}
    do
        cp -r /home/mysql/canal-server/conf/example /home/mysql/canal-server/conf/$prefix$var
        chown mysql:mysql -R /home/mysql/canal-server/conf/$prefix$var
        if [[ "$prefix$var" = 'example' ]] ; then
            holdExample="true"
        fi
    done
    if [[ "$holdExample" != 'true' ]] ; then
        rm -rf /home/mysql/canal-server/conf/example
    fi
}

function stop_canal() {
    echo "stop canal server"
    bash /home/mysql/canal-server/bin/stop.sh 1>>/tmp/start.log 2>&1
    echo "stop canal server successful ..."
}

function start_canal_adapter(){
    echo "start canal adapter..."
    
    bash /home/mysql/canal-adapter/bin/stop.sh 1>>/tmp/start.log 2>&1
    bash /home/mysql/canal-adapter/bin/startup.sh 1>>/tmp/start.log 2>&1

    sleep 5
        #check start
    checkStart "canal-adapter" "nc -v -z -w 1 127.0.0.1 8081 &> /dev/null && echo 'Port is Open' || echo ''" 30 

    echo "start canal adapter successful ..."
}


function stop_canal_adapter(){
    echo "stop canal adapter"
    bash /home/mysql/canal-adapter/bin/stop.sh 1>>/tmp/start.log 2>&1
    echo "stop canal adapter successful ..."
}

function start_exporter() {
    su mysql -c 'cd /home/mysql/node_exporter && ./node_exporter 1>>/tmp/start.log 2>&1 &'
}

function stop_exporter() {
    su mysql -c 'killall node_exporter'
}

function start_mariadb(){
    echo "start mariadb $@"

    bash /home/mysql/mariadb-entrypoint.sh "$@" 1>>/tmp/start.log 2>&1 &

    sleep 5
    checkStart "mariadb" "nc -v -z -w 1 127.0.0.1 3306 &> /dev/null && echo 'Port is Open' || echo ''" 30
    echo "start mariadb successful ..."

}

echo "==> START ..."

start_mariadb "$@"
# start_exporter
start_canal

start_canal_adapter

echo "==> START SUCCESSFUL ..."

tail -f /dev/null &
# wait TERM signal
waitterm

echo "==> STOP"

stop_canal_adapter

stop_canal
# stop_exporter

echo "==> STOP SUCCESSFUL ..."
