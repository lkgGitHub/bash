#!/bin/bash
tar zxvf apache-hive-2.2.0-bin.tar.gz -C /opt
mv /opt/apache-hive-2.2.0-bin/ /opt/hive

echo "export HIVE_HOME=/opt/hive
export PATH=$PATH:$HIVE_HOME/bin">> /etc/profile
source /etc/profile

$HADOOP_HOME/bin/hadoop fs -mkdir       /tmp
$HADOOP_HOME/bin/hadoop fs -mkdir   -p  /user/hive/warehouse
$HADOOP_HOME/bin/hadoop fs -chmod a+w   /tmp
$HADOOP_HOME/bin/hadoop fs -chmod a+w   /user/hive/warehouse

schematool -initSchema -dbType derby