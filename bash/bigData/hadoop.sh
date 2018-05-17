#!/bin/bash
# 定义变量
master=host1
slave1=host2
slave2=host3

# 解压安装
tar zxvf hadoop-2.7.4.tar.gz  -C /opt/
mv hadoop-2.7.4/ hadoop
cd /opt/hadoop/etc/hadoop
echo "export JAVA_HOME=/opt/jdk" >>hadoop-env.sh
sed -i -e '23a export JAVA_HOME=/opt/jdk'yarn-env.sh

sed -i '1d' slaves   
echo "$slave1 
$slave2
">> slaves

# 删除文件的第18行到20行所有行：
sed -i '19,20d' core-site.xml
echo > core-site.xml   
echo "<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://$master:9000/</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>file:/opt/hadoop/tmp</value>
    </property>
</configuration>
" >>core-site.xml

sed -i '19,21d' hdfs-site.xml   
echo "<configuration>
    <property>
        <name>dfs.namenode.secondary.http-address</name>
        <value>$master:9001</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:/opt/hadoop/dfs/name</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:/opt/hadoop/dfs/data</value>
    </property>
    <property>
        <name>dfs.replication</name>
        <value>3</value>
    </property>
</configuration>
">>hdfs-site.xml

cp mapred-site.xml.template mapred-site.xml
sed -i '19,21d' mapred-site.xml 
echo "<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
       <name>yarn.app.mapreduce.am.resource.mb</name>
       <value>1024</value>
     </property>
</configuration>
">> mapred-site.xml

sed -i '15,19d' yarn-site.xml
echo "<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
    <property>
        <name>yarn.resourcemanager.address</name>
        <value>$master:8032</value>
    </property>
    <property>
        <name>yarn.resourcemanager.scheduler.address</name>
        <value>$master:8030</value>
    </property>
    <property>
        <name>yarn.resourcemanager.resource-tracker.address</name>
        <value>$master:8035</value>
    </property>
    <property>
        <name>yarn.resourcemanager.admin.address</name>
        <value>$master:8033</value>
    </property>
    <property>
        <name>yarn.resourcemanager.webapp.address</name>
        <value>$master:8088</value>
</property>
 <property>
      <name>yarn.nodemanager.resource.memory-mb</name>
      <value>1536</value>
  </property>
    <property>
    <name>yarn.nodemanager.resource.cpu-vcores</name>
    <value>1</value>
</property>
<property>
        <name>yarn.nodemanager.vmem-check-enabled</name>
        <value>false</value>
</property>
</configuration>
">>yarn-site.xml

scp -r /opt/hadoop $slave1:/opt/
scp -r /opt/hadoop $slave2:/opt/

scp -r /etc/profile $slave1:/etc/
scp -r /etc/profile $slave2:/etc/

/opt/hadoop/bin/hadoop namenode -format 
/opt/hadoop/sbin/start-dfs.sh
/opt/hadoop/sbin/start-yarn.sh

