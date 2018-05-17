#!/bin/bash
echo -e "\033[34m =============zabbix-agent============== \033[0m"
zabbix_server_ip="11.11.209.139"
Hname = DSJmysql6
yum -y localinstall zabbix-agent-3.0.7-1.el6.x86_64.rpm
sed -i -e "s|Server=127.0.0.1|Server= $zabbix_server_ip|" /etc/zabbix/zabbix_agentd.conf
sed -i -e "s|ServerActive=127.0.0.1|ServerActive = $zabbix_server_ip|" /etc/zabbix/zabbix_agentd.conf
sed -i -e "146c Hostname=$Hname" /etc/zabbix/zabbix_agentd.conf
service zabbix-agent start

 #GRANT PROCESS,SUPER,REPLICATION CLIENT ON *.* TO zabbix@'localhost' IDENTIFIED BY 'cZOEpL9J'; 
#sed -i 's|/var/lib/zabbix|/etc/zabbix|g' /etc/zabbix/zabbix_agentd.d/userparameter_mysql.conf
#检查：zabbix_get -s 11.11.209.139 -p 10050 -k "mysql.status[Uptime]"

