#! /bin/bash
serverId=1
VIP=""
slaveIp=""
password=""
virtual_router_id=82  #80,90,81已经被用
localIp=$(LC_ALL=C ifconfig|grep "inet addr:"|grep -v "127.0.0.1"|cut -d: -f2|awk '{print $1}')

rpm -qa|grep mysql
# 通常系统自带mysql-libs，将其卸载
echo -e "\033[32m ==========卸载系统自带mysql-libs========== \033[0m"
yum remove mysql-libs -y

echo -e "\033[32m ==========解压mysql========== \033[0m"
tar -xvf MySQL-5.6.35-1.el6.x86_64.rpm-bundle.tar

echo -e "\033[32m ==========yum本地安装mysql========== \033[0m"
yum localinstall MySQL-client-5.6.35-1.el6.x86_64.rpm MySQL-server-5.6.35-1.el6.x86_64.rpm MySQL-devel-5.6.35-1.el6.x86_64.rpm

# 查看随机初始密码
echo -e "\033[32m ==========请复制好默认随机密码========== \033[0m"
cat /root/.mysql_secret
echo -e "\033[32m ==========修改mysql配置文件========== \033[0m"
echo "[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
server-id=$serverId
log-bin=mysqlbin-log
symbolic-links=0
default-storage-engine=INNODB
character-set-server=utf8
collation-server=utf8_general_ci

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid     #需要授权

[client]
default-character-set=utf8">>/etc/my.cnf
echo -e "\033[32m ==========启动mysql========== \033[0m"
service mysql start
echo -e "\033[32m ==========初始化mysql========== \033[0m"
# 初始化mysql
/usr/bin/mysql_secure_installation

echo -e "\033[32m ==========安装keepalived========= \033[0m"
yum install keepalived -y
echo -e "\033[32m ==========修改keepalived配置文件========= \033[0m"
mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak
echo "! Configuration File for keepalived
 
global_defs {
   notification_email {
     root@huangmingming.cn
   }
   notification_email_from keepalived@localhost  
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id LVS_DEVEL
}
 
vrrp_instance HA_1 {
    state BACKUP                #master和slave都配置为BACKUP
    interface eth0              #指定HA检测的网络接口
    virtual_router_id $virtual_router_id        #虚拟路由标识，主备相同
    priority 100                #定义优先级，slave设置90
    advert_int 1                #设定master和slave之间同步检查的时间间隔
    nopreempt                   #不抢占模式。只在优先级高的机器上设置即可
    authentication {
        auth_type PASS
        auth_pass 1111
    }
 
    virtual_ipaddress {          #设置虚拟IP，可以设置多个，每行一个
        $VIP                     #MySQL对外服务的IP，即VIP
    }
}
 
virtual_server $VIP 3306 {
    delay_loop 2                    #每隔2秒查询real server状态
    lb_algo wrr                     #lvs 算法
    lb_kinf DR                      #LVS模式（Direct Route）
    persistence_timeout 50
    protocol TCP
 
    real_server $localIp 3306 {    #监听本机的IP
        weight 1
        notify_down /etc/keepalived/mysql.sh
        TCP_CHECK {
        connect_timeout 10         #10秒无响应超时
        bingto $VIP
        nb_get_retry 3
        delay_before_retry 3
        connect_port 3306
        }
    }
}
">>/etc/keepalived/keepalived.conf
echo -e "\033[32m ==========添加mysql.sh========= \033[0m"
echo "#!/bin/bash
pkill keepalived" >>/etc/keepalived/mysql.sh
chmod +x /etc/keepalived/mysql.sh

echo -e "\033[34m =======设置mysql主主同步======== \033[0m"
mysql -uroot -p$password -e "grant replication slave on *.* to slave@$slaveIp identified by $password;flush privileges;"
mysql -uroot -p$password -e "change master to master_host=$slaveIp, master_user='slave', master_password=$password;start slave;"
echo -e "\033[34m =======请通过show slave status\G;检查是否成功======== \033[0m"
mysql -uroot -p$password 


