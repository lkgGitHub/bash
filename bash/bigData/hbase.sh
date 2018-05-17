#!/bin/bash
# 定义变量
master=host1
slave1=host2
slave2=host3

tar zxvf hbase-1.2.6-bin.tar.gz -C /opt
mv hbase-1.2.6/ hbase 
cd hbase/

sed -i -e '28a export JAVA_HOME=/opt/jdk' /opt/hbase/conf/hbase-env.sh

sed -i '23,24d' /opt/hbase/conf/hbase-site.xml
echo "<configuration>
  <property>
    <name>hbase.cluster.distributed</name>
    <value>true</value>
  </property>
  <property>
    <name>hbase.zookeeper.quorum</name>
    <value>$master,$slave1,$slave2</value>
  </property>
  <property>
    <name>hbase.zookeeper.property.dataDir</name>
     <value>/usr/local/zookeeper</value>
  </property>
  <property>
      <name>hbase.rootdir</name>
      <value>hdfs://$master:9000/hbase</value>
  </property>
</configuration>
">>/opt/hbase/conf/hbase-site.xml

echo "$slave1 
$slave2
"> /opt/hbase/conf/regionservers

echo "$slave1" > /opt/hbase/conf/backup-masters

scp -r /opt/hbase $slave1:/opt/
scp -r /opt/hbase $slave2:/opt/

/opt/hbase/bin/start-hbase.sh