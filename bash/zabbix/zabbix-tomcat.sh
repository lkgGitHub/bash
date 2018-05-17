#!/bin/bash
zabbix_server_ip="11.11.209.139"
Hname = DSJmysql6
echo -e "\033[34m =============zabbix-agent============== \033[0m"
yum localinstall zabbix-agent-3.0.7-1.el6.x86_64.rpm zabbix-java-gateway-3.0.7-1.el6.x86_64.rpm 
echo -e "\033[34m =============修改zabbix-java-gateway配置文件============== \033[0m"
sed -i -e '10c LISTEN_IP="127.0.0.1"' /etc/zabbix/zabbix_java_gateway.conf
sed -i -e "17c LISTEN_PORT=10052 " /etc/zabbix/zabbix_java_gateway.conf
# 开启的工作线程数（必须大于等于后面zabbix_server.conf文件的StartJavaPollers参数） #必须配置，启动的进出数
sed -i -e "36c START_POLLERS=50" /etc/zabbix/zabbix_java_gateway.conf
echo -e "\033[34m =============修改zabbix-agent配置文件============== \033[0m"
sed -i -e "s|Server=127.0.0.1|Server= $zabbix_server_ip|" /etc/zabbix/zabbix_agentd.conf
sed -i -e "s|ServerActive=127.0.0.1|ServerActive = $zabbix_server_ip|" /etc/zabbix/zabbix_agentd.conf
sed -i -e "147c Hostname=$Hname" /etc/zabbix/zabbix_agentd.conf