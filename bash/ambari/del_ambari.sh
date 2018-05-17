#!/bin/bash
# Program:
#    uninstall ambari 
#PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
#export PATH
#curl -u admin:admin -H "X-Requested-By: ambari" -X DELETE  http://bd-app-06:8080/api/v1/clusters/pdmi/services/HIVE
# mysql密码
pd=123456

ambari-server stop
/etc/init.d/ambari-agent stop
yum remove -y hdp-select 
yum remove -y smartsense*  
yum remove -y bigtop-tomcat.noarch
yum remove -y bigtop-jsvc
yum remove -y ranger* 
#删除HDP相关的安装包
yum remove -y  "hadoop*"
yum remove -y  hbase*
yum remove -y  pig*
yum remove -y  tez* 
yum remove -y  ambari-*
yum remove -y  oozie*
yum remove -y  hive*	
yum remove -y zookeeper*
yum remove -y spark*	
yum remove -y "slider*"
yum remove -y flume*
yum remove -y kafka*
yum remove -y storm*

echo -e "\033[34m 删除文件夹 \033[0m"
#删除文件夹
rm -rfv /data/hadoop
rm -rfv /usr/hdp
rm -rfv /hadoop 
rm -rfv /etc/hadoop* 
rm -rfv /etc/hbase*
rm -rfv /etc/hive*
rm -rfv /etc/oozie
rm -rfv /etc/sqoop
rm -rfv /etc/zookeeper
rm -rfv /etc/tez	  
rm -rfv /var/run/hadoop* 
rm -rfv /var/run/hbase*
rm -rfv /var/run/hive*
rm -rfv /var/run/oozie
rm -rfv /var/run/zookeeper*

rm -rfv /var/log/hadoop*
rm -rfv /var/log/hbase*
rm -rfv /var/log/hive* 
rm -rfv /var/log/oozie*
rm -rfv /var/log/zookeeper* 
rm -rfv /usr/lib/hbase*
rm -rfv /usr/lib/hive*
rm -rfv /usr/lib/oozie*
rm -rfv /usr/lib/sqoop*
rm -rfv /usr/lib/zookeeper* 
rm -rfv /usr/lib/ambari-*
rm -rfv /var/lib/hive*
rm -rfv /var/lib/oozie*
rm -rfv /var/lib/zookeeper*
rm -rfv /var/lib/hadoop-*	
rm -rfv /tmp/hive* 
rm -rfv /tmp/ambari* 

rm -rfv /tmp/hadoop* 
rm -rfv /tmp/hsperfdata*
rm -rfv /tmp/hbase-*
rm -rfv /usr/bin/zookeeper* 
rm -rfv /var/run/spark
rm -rfv /var/log/spark
rm -rfv /etc/spark
rm -rfv /usr/bin/spark*	
rm -rfv /etc/slider
rm -rfv /usr/bin/slider
rm -rfv /etc/pig
rm -rfv /usr/bin/pig
rm -rfv /usr/bin/kafka	
rm -rfv /etc/security/limits.d/hive.conf
rm -rfv /usr/bin/hiveserver2
rm -rfv /usr/bin/hbase
rm -rfv /etc/security/limits.d/hbase.conf

rm -rfv /usr/bin/hadoop
rm -rfv /var/run/ambari*
rm -rfv /usr/sbin/ambari_server_main.pyc
rm -rfv /usr/lib/flume/lib/ambari-metrics-flume-sink.jar
rm -rfv /usr/lib/python2.6/site-packages/ambari*
rm -rfv /usr/lib/python2.6/site-packages/resource_monitoring/ambari_commons
rm -rfv /var/run/flume/ambari-state.txt
rm -rfv /usr/lib/python2.6/site-packages/resource_management
rm -rfv rm -rf /tmp/hcat/
rm -rfv /etc/ams-hbase
rm -rfv /var/lib/ambari*
rm -rfv /var/log/ambari*
rm -rfv /evtc/ambari*

#oozie*
rm -rfv /usr/bin/oozie
rm -rfv /usr/bin/oozie*
rm -rfv /var/tmp/oozie
rm -rfv /var/spool/mail/oozie
rm -rfv /home/oozie
rm -rfv /tmp/oozie*
rm -rfv /oozie
rm -rfv /oozieModel
rm -rfv /usr/local/oozie*
rm -rfv /usr/fsx/oozie
rm -rfv /usr/local/lib64/oozie.workflow-0.0.1-SNAPSHOT.jar
rm -rfv /var/lib/knox/data-2.4.2.0-258/services/oozie
rm -rfv /var/spool/mail/kafka
rm -rfv /var/run/kafka
rm -rfv /var/log/kafka
rm -rfv /kafka-logs
rm -rfv /etc/kafka
rm -rfv /etc/security/limits.d/kafka.conf
rm -rfv /home/kafka
rm -rfv /var/lib/slider
rm -rfv /usr/bin/hive
rm -rfv /var/lib/mysql/hive
rm -rfv /tmp/root/hive*
rm -rfv /usr/lib/ams-hbase
#删除flume
rm -rfv /etc/flume
rm -rfv /var/log/flume
rm -rfv /var/run/flume
rm -rfv /var/lib/flume
rm -rfv /usr/bin/flume-ng
rm -rfv /usr/lib/flume
#删除sqoop
rm -rfv /var/run/sqoop
rm -rfv /var/log/sqoop
rm -rfv /usr/bin/sqoop*
#删除storm
rm -rfv /etc/storm*
rm -rfv /usr/bin/storm*
rm -rfv /usr/lib/storm
rm -rfv /usr/work/app-packages/storm
rm -rfv /var/lib/storm
rm -rfv /var/log/storm
rm -rfv /var/run/storm

#删除配置记录
rm -rfv /etc/accumulo/conf.backup/
rm -rfv /etc/accumulo/2.4.2.0-258/

#删除清空mysql
echo -e "\033[34m 删除清空mysql \033[0m"
mysql -uroot -p$pd -e "drop database ambari;" && echo "删除ambari数据库成功"
service mysqld stop
# 卸载mysql
# rpm -ev mysql-connector-java-5.1.17-6.el6.noarch
# rpm -e --nodeps mysql-libs-5.1.73-7.el6.x86_64
# rpm -ev mysql-5.1.73-7.el6.x86_64
# rpm -ev mysql-server-5.1.73-7.el6.x86_64
# rm -rf /usr/lib64/perl5/DBD/mysql
# rm -rf /usr/lib64/perl5/auto/DBD/mysql
# rm -rf /var/lib/mysql
# rm -rf /var/lock/subsys/mysql
# rm -rf /usr/local/mysql
# rm -rf /etc/my.cnf
# rm -rf /usr/share/mysql
# rm -rf /usr/lib64/mysql
# rm -rf /usr/bin/mysql
# rm -rf /usr/include/mysql
# rm -rf /usr/include/mysql/mysql
# rm -rf /etc/rc.d/init.d/mysql
# rm -rf /etc/logrotate.d/mysql


#????（2016.12.9）(host2 h和host3）
#yum remove -y  snappy-devel.x86_64	
#yum remove -y  snappy.x86_64
#yum remove -y  epel-release.noarch
#yum remove -y  compat-readline5

#其他和用户文件夹
echo -e "\033[34m 删除用户 \033[0m"
userdel -r zookeeper	
userdel -r ambari-qa	
userdel -r ams	
userdel -r hdfs	
userdel -r yarn	
userdel -r mapred	
userdel -r hive	
userdel -r spark	
userdel -r kafka	
userdel -r tez	
userdel -r hcat	
userdel -r hbase	
userdel -r storm	
userdel -r sqoop	
userdel -r flume

# rm -rfv /home/zookeeper
# rm -rfv /home/tez
# rm -rfv /home/spark
# rm -rfv /home/hive
# rm -rfv /home/hbase
# rm -rfv /home/sqoop
# rm -rfv /home/flume
# rm -rfv /home/ambari-qa
# rm -rfv /var/spool/mail/zookeeper
# rm -rfv /var/spool/mail/tez
# rm -rfv /var/spool/mail/spark
# rm -rfv /var/spool/mail/slider
# rm -rfv /var/spool/mail/hive
# rm -rfv /var/spool/mail/hbase
# rm -rfv /var/spool/mail/sqoop
# rm -rfv /var/spool/mail/flume
# rm -rfv /var/spool/mail/ambari-qa
rm -rfv /usr/lib/ams-hbase/docs/xref/org/apache/hadoop/hbase/zookeeper
rm -rfv /usr/lib/ams-hbase/docs/xref-test/org/apache/hadoop/hbase/zookeeper

echo -e "\033[34m successful \033[0m"

rm -rfv /usr/bin/hdfs
rm -rfv /etc/security/limits.d/hdfs.conf
rm -rfv /usr/bin/yarn
rm -rfv /etc/security/limits.d/mapreduce.conf
rm -rfv /etc/security/limits.d/yarn.conf
rm -rfv /var/tmp/sqoop
rm -rfv /etc/ambari-agent
rm -rfv /var/spool/mail/hdfs
rm -rfv /home/hdfs
rm -rfv /var/spool/mail/yarn
rm -rfv /home/yarn
rm -rfv /usr/bin/ranger*
rm -rf /etc/ambari-metrics-monitor
rm -rf /var/run/webhcat
rm -rf /var/log/webhcat
