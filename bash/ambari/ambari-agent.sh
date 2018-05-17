#! /bin/bash
ip_ntp=192.168.101.1


yum -y install openssh-clients
echo -e "\033[34m ===========close THP ============== \033[0m"
echo 'if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
 echo never > /sys/kernel/mm/transparent_hugepage/enabled
 fi
 if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
 echo never > /sys/kernel/mm/transparent_hugepage/defrag
 fi ' >> /etc/rc.d/rc.local && echo "关闭THP成功"

echo -e "\033[34m ==========close iptables ========== \033[0m"
chkconfig --level 2345 iptables off
/etc/init.d/iptables stop
/etc/init.d/iptables status
echo -e "\033[34m ============yum openssl============ \033[0m"
yum -y install openssl
echo -e "\033[34m ============NTP时间同步============ \033[0m"
yum -y install ntp
service ntpd start
chkconfig ntpd on
ntpdate $ip_ntp
echo -e "\033[34m ============关闭selinux============ \033[0m"
sed -i -e 's|SELINUX=enforcing|SELINUX=disabled|' /etc/selinux/config
#在"#End of file"前加入一下内容
echo -e "\033[34m ========修改系统Linux限制值======== \033[0m"
sed -i '/# End of file/i\*             -    nofile           605536' /etc/security/limits.conf
sed -i '/# End of file/i\*             -    nproc            32000' /etc/security/limits.conf

echo "vm.swappiness = 1" >> /etc/sysctl.conf
echo "vm.overcommit_ratio = 95" >> /etc/sysctl.conf
echo "vm.overcommit_memory = 2" >> /etc/sysctl.conf
echo "net.core.somaxconn = 2048" >> /etc/sysctl.conf
sysctl -p
