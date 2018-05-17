#!/bin/bash
# 定义变量
master=host1
slave1=host2
slave2=host3

ip=$(LC_ALL=C ifconfig|grep "inet addr:"|grep -v "127.0.0.1"|cut -d: -f2|awk '{print $1}')


tar zxvf scala-2.12.3.tgz -C /opt/
mv scala-2.12.3/ scala

echo 'export SCALA_HOME=/opt/scala 
export PATH=$PATH:$SCALA_HOME/bin
'>> /etc/profile
source /etc/profile
scala -version

scp -r /opt/scala $slave1:/opt
scp -r /opt/scala $slave2:/opt


tar zxvf spark-2.2.0-bin-hadoop2.7.tgz -C /opt/
mv spark-2.2.0-bin-hadoop2.7/ spark
cp /opt/spark/conf/spark-env.sh.template /opt/spark/conf/spark-env.sh 
echo 'export SPARK_HOME=/opt/spark
export SCALA_HOME=/opt/scala
export JAVA_HOME=/opt/jdk
export HADOOP_HOME=/opt/hadoop
export PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SCALA_HOME/bin
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export YARN_CONF_DIR=$YARN_HOME/etc/hadoop
'>>/opt/spark/conf/spark-env.sh 
echo "export SPARK_MASTER_IP=$ip" >>/opt/spark/conf/spark-env.sh
echo 'SPARK_LOCAL_DIRS=/opt/spark
SPARK_DRIVER_MEMORY=1G
export SPARK_LIBARY_PATH=.:$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$HADOOP_HOME/lib/native
'>>/opt/spark/conf/spark-env.sh 

cp /opt/spark/conf/slaves.template /opt/spark/conf/slaves
echo "$slave1
$slave2
" >/opt/spark/conf/slaves

scp -r /opt/spark $slave1:/opt
scp -r /opt/spark $slave2:/opt
scp /etc/profile $slave1:/etc
scp /etc/profile $slave2:/etc
ssh $slave1 "source /etc/profile"
ssh $slave2 "source /etc/profile"
ssh $slave1 "scala -version"
ssh $slave2 "scala -version"

/opt/spark/sbin/start-all.sh