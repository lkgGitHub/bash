#! /bin/bash
java_home= 

sed -i '/# End of file/i\*    soft    nofile    65535' /etc/security/limits.conf
sed -i '/# End of file/i\*    hard    nofile    65535' /etc/security/limits.conf
sed -i '/# End of file/i\*    soft    nproc    65535' /etc/security/limits.conf
sed -i '/# End of file/i\*    hard    nproc    65535' /etc/security/limits.conf

echo "net.core.netdev_max_backlog = 32768
net.core.somaxconn = 32768
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 65536
">>/etc/sysctl.conf

tar -zxvf apache-tomcat-7.0.77.tar.gz -C /usr/local/
ln -s /usr/local/apache-tomcat-7.0.77/ /usr/local/tomcat

sed -i -e "105a export JAVA_HOME=$java_home" /usr/local/tomcat/bin/catalina.sh
sed -i -e '106a JAVA_OPTS="$JAVA_OPTS -Xmx1024M -Xms1024M -XX:MaxPermSize=512m -XX:PermSize=256m"' /usr/local/tomcat/bin/catalina.sh
sed -i -e '107a JAVA_OPTS="$JAVA_OPTS -XX:+HeapDumpOnOutOfMemoryError"' /usr/local/tomcat/bin/catalina.sh
sed -i -e '108a export JAVA_OPTS' /usr/local/tomcat/bin/catalina.sh
sed -i -e '109a CATALINA_HOME=/usr/local/tomcat' /usr/local/tomcat/bin/catalina.sh

cp /usr/local/tomcat/bin/catalina.sh /etc/init.d/tomcat



