#!bin/bash

#记住当前路径
Cur_Dir=$(pwd)
echo $Cur_Dir

echo -e "\033[34m =======安装本地mysql======= \033[0m"
groupadd mysql
useradd -g mysql mysql
tar -zxvf mysql-advanced-5.6.23-linux-glibc2.5-x86_64.tar.gz -C /usr/local/
mv /usr/local/mysql-advanced-5.6.23-linux-glibc2.5-x86_64 /usr/local/mysql
cd /usr/local/mysql
chown -R mysql:mysql /usr/local/mysql
cp ./support-files/my-default.cnf /etc/my.cnf
echo -e "\033[34m =========覆盖mysql配置文件，请输入yes============ \033[0m"
cp ./support-files/mysql.server /etc/rc.d/init.d/mysqld
echo -e "\033[34m =================初始化数据库===================== \033[0m"
scripts/mysql_install_db --user=mysql
chown -R root . 
chown -R mysql data

echo -e "\033[34m =======install ambari-server======== \033[0m"
yum -y install ambari-server

echo -e "\033[34m =======启动并配置mysql======== \033[0m"
service mysqld start
/usr/local/mysql/bin/mysqladmin -u root password 123456
mysql -uroot -p123456 <<EOP
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'hive'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'oozie'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
use mysql;
delete from user where User="" or Password="";
flush privileges;
CREATE DATABASE ambari;
CREATE DATABASE bdp;
CREATE DATABASE oozie;
use ambari;
source /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql;
exit;
EOP
mysql -uroot -p123456 -e "use bdp;source $Cur_Dir/bdp.sql;"&& echo "导入BDP数据路成功"

echo -e "\033[36m ==========安装mysql jdbc============\033[0m"
mkdir /usr/share/java
cd $Cur_Dir
cp mysql-connector-java-5.1.40-bin.jar /usr/share/java/
cd /usr/share/java
ln -s mysql-connector-java-5.1.40-bin.jar mysql-connector-java.jar

echo -e "\033[34m ============重启mysql============== \033[0m"
service mysqld restart
service mysqld status
service mysqld stop

echo -e "\033[34m =======检查无误后请重启电脑========== \033[0m"
