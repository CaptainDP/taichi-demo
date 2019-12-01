#!/usr/bin/env bash

##-*-coding: utf-8; mode: shell-script;-*-##

set -e
umask 0000

APP_HOME="$(cd $(dirname $0)/..; pwd -P)"

set -a
source "$APP_HOME/etc/run_online.env"
set +a

if [[ $# -eq 2 ]]; then
    dt=$(date -d "$1" +%Y%m%d)
    conffile="$2"
elif [[ $# -eq 3 ]]; then
    dt=$(date -d "$1" +%Y%m%d)
    conffile="$2"
    json="$3"
else
    echo "$0 date conffile"
    exit 1
fi

export LOG_FILE=$conffile
export LOG_DATE=$dt

if [ ${conffile:0:1} != "/" ]
then
    conffile="$APP_HOME/conf/$conffile"
fi

logging "base date $dt to process: $conffile"

filelist="$APP_HOME/conf/taichi.json,$APP_HOME/conf/log4j.properties,$conffile"

export SPARK_CLASSPATH=$SPARK_CLASSPATH":$APP_HOME/conf:$APP_HOME/etc:$APP_HOME/libs/*"

cls="$APP_CLS"
jar="$APP_HOME/libs/$APP_JAR"

cmd="spark-submit"
cmd="$cmd --conf spark.sql.warehouse.dir=file://$(pwd)/sparksql/warehouse"
cmd="$cmd --conf spark.app.name=taichi_demo-$conffile-$dt"
cmd="$cmd --conf spark.yarn.submit.waitAppCompletion=true"
cmd="$cmd --files ${filelist}"
cmd="$cmd --num-executors 2 --executor-cores 2 --executor-memory 1GB"

cmd="$cmd --conf spark.driver.extraJavaOptions=-Dfile.encoding=utf-8"
cmd="$cmd --conf spark.executor.extraJavaOptions=-Dfile.encoding=utf-8"

cmd="$cmd --master local[*]"
#cmd="$cmd --master yarn"

cmd="$cmd --deploy-mode client"
#cmd="$cmd --deploy-mode cluster"

cmd="$cmd --conf spark.port.maxRetries=30"
cmd="$cmd --conf spark.speculation=true"
cmd="$cmd --name taichi-demo-$conffile-$dt"
cmd="$cmd --class $cls $jar"
cmd="$cmd -d $dt"
cmd="$cmd -cf $conffile"
cmd="$cmd -a $json"

LOG_FILE=${conffile//\//_}_$dt
logging "command to execute: $cmd"
LOG_DIR=$LOG_HOME/$dt

$cmd

logging 'all OK'
