#!/bin/bash
# cZOEpL9J
mysqlpd=123456
echo -e "\033[34m ============卸载已存在的mysql-libs ============== \033[0m"
rpm -qa|grep mysql
yum remove mysql-libs
rpm -qa|grep mysql
echo -e "\033[34m ============解压mysql ============== \033[0m"
tar -xvf MySQL-5.6.35-1.el6.x86_64.rpm-bundle.tar
echo -e "\033[34m =======install mysql======== \033[0m"
yum -y localinstall MySQL-server-5.6.35-1.el6.x86_64.rpm MySQL-client-5.6.35-1.el6.x86_64.rpm MySQL-devel-5.6.35-1.el6.x86_64.rpm
echo -e "\033[34m =======修改mysql配置文件======== \033[0m"
touch /etc/my.cnf
echo "[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
log-bin=mysqlbin-log
symbolic-links=0
default-storage-engine=INNODB
character-set-server=utf8
collation-server=utf8_general_ci

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
[client]
default-character-set=utf8">>/etc/my.cnf
echo -e "\033[34m =======初始化mysql======== \033[0m"
cat /root/.mysql_secret
service mysql start
# 初始化mysql
/usr/bin/mysql_secure_installation
service mysql status

echo -e "\033[34m =============安装php ============== \033[0m"
touch /etc/yum.repos.d/yum.repo
echo "[php]
name=php
baseurl=http://10.2.45.80/php
enabled=1
gpgcheck=0 ">>/etc/yum.repos.d/yum.repo
yum --enablerepo=yum install php php-gd php-bcmath php-xml php-mbstring php-ctype php-xmlreader php-xmlwriter php-net-socket php-gettext php-common php-mysql php-opcache php-devel  php-mcrypt php-mysqlnd php-phpunit-PHPUnit php-pecl-xdebug php-pecl-xhprof php-pdo php-pear php-cli  php-process php-fpm 
# 检验安装版本
php -v;

echo -e "\033[34m =============安装zabbix-server ============== \033[0m"
touch /etc/yum.repos.d/yum.repo
echo "[yum]
name=yum
baseurl=http://10.2.45.80/yum
enabled=1
gpgcheck=0 ">>/etc/yum.repos.d/yum.repo
yum install zabbix-server-mysql zabbix-web-mysql

#需要手动执行
#mysql -uroot -p123456 -e "CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;GRANT ALL PRIVILEGES ON zabbix.* TO zabbix@localhost IDENTIFIED BY "123456";flush PRIVILEGES;"&& echo "数据导入成功"

echo -e "\033[34m =============初始化zabbix数据库，请输入mysql密码 ============== \033[0m"
zcat /usr/share/doc/zabbix-server-mysql-3.0.7/create.sql.gz | mysql -uzabbix -p zabbix

echo -e "\033[34m =============修改zabbix_server.conf============== \033[0m"
sed -i -e "115a DBPassword = $pd" /etc/zabbix/zabbix_server.conf

echo -e "\033[34m =============Zabbix前端的PHP配置============== \033[0m"
cp /usr/share/doc/zabbix-web-3.0.7/httpd22-example.conf /etc/httpd/conf.d/zabbix.conf
sed -i -e "20c php_value date.timezone Asia/shanghai" /etc/httpd/conf.d/zabbix.conf
chmod -R 755 /etc/zabbix/web
chown -R apache.apache /etc/zabbix/web

echo -e "\033[34m =============修改php配置文件============== \033[0m"
sed -i -e 's|post_max_size = 8M|post_max_size = 16M|' /etc/php.ini
sed -i -e 's|max_execution_time = 30|max_execution_time = 300|' /etc/php.ini
sed -i -e 's|max_input_time = 60|max_input_time = 300|' /etc/php.ini
sed -i -e 's|spost_max_size = 8M|post_max_size = 16M|' /etc/php.ini
sed -i -e "890c date.timezone = Asia/shanghai" /etc/php.ini
sed -i -e "706c always_populate_raw_post_data=-1" /etc/php.ini

echo -e "\033[34m =============修改httpd============== \033[0m"
sed -i -e "277c ServerName localhost:80" /etc/httpd/conf/httpd.conf 

echo -e "\033[34m =============启动zabbix，httpd，php-fpm============== \033[0m"
service zabbix-server start
service httpd start
chkconfig httpd on
/etc/init.d/php-fpm start
chkconfig php-fpm on

ip=$(LC_ALL=C ifconfig|grep "inet addr:"|grep -v "127.0.0.1"|cut -d: -f2|awk '{print $1}')
echo -e "\033[34m =============http://$ip/zabbix============== \033[0m"

# echo -e "\033[34m =============zabbix-agent============== \033[0m"
# zabbix_server_ip=
# Hname = 
# yum localinstall zabbix-agent-3.0.7-1.el6.x86_64.rpm
# sed -i -e "s|Server=127.0.0.1|Server=  $zabbix_server_ip|" /etc/zabbix/zabbix_agentd.conf
# sed -i -e "s|ServerActive=127.0.0.1|ServerActive =  $zabbix_server_ip|" /etc/zabbix/zabbix_agentd.conf
# sed -i -e "s|Hostname=Zabbix server|Hostname=$Hname|" /etc/zabbix/zabbix_agentd.conf
# service zabbix-agent start