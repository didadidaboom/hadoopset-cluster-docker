#!/bin/bash

echo -e "\n"

$HADOOP_HOME/sbin/start-dfs.sh

echo -e "\n"

$HADOOP_HOME/sbin/start-yarn.sh

echo -e "\n"

$HIVE_HOME/bin/start-hive.sh

echo -e "\n"

$HBASE_HOME/bin/start-hbase.sh

