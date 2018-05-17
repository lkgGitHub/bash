#! /bin/bash

ALL_CLIENTS=`cat /etc/hosts| grep "192.168.101" | awk '{print $2}'`
CLIENTS=""
ip_NTP=$(LC_ALL=C ifconfig|grep "inet addr:"|grep -v "127.0.0.1"|cut -d: -f2|awk '{print $1}')


echo -e "\033[34m =============更新yum ============== \033[0m"
yum clean all
yum update
echo -e "\033[34m ======安装上传下载工具lrzsz====== \033[0m"
yum -y install lrzsz
echo -e "\033[32m =======close iptables ====== \033[0m"
for client in $ALL_CLIENTS
do
    echo -e "\033[34m ======close iptables at $client====== \033[0m"
    ssh $client "chkconfig --level 2345 iptables off"
    ssh $client "/etc/init.d/iptables stop && /etc/init.d/iptables status"
done
echo -e "\033[32m ==========yum openssl========== \033[0m"
for client in $ALL_CLIENTS
do
    echo -e "\033[34m ======yum openssl at $client====== \033[0m"
    ssh $client "yum -y install openssl"
done
echo -e "\033[32m ==========NTP时间同步========== \033[0m"
for client in $ALL_CLIENTS
do
    echo -e "\033[34m ======NTP at $client====== \033[0m"
    ssh $client "yum -y install ntp && chkconfig ntpd on && service ntpd start"
    ssh $client "ntpdate $ip_NTP"
done

echo -e "\033[32m ==========修改linux配置========== \033[0m"
echo -e "\033[32m ==========禁用SELinuxSELinux和PackageKit========== \033[0m"
for client in $ALL_CLIENTS
do
    echo -e "\033[34m ======禁用SELinux和PackageKit at $client====== \033[0m"
    ssh $client "sed -i -e 's|SELINUX=enforcing|SELINUX=disabled|' /etc/selinux/config"
done
# echo -e "\033[32m ==========检查最大打开文件描述符========== \033[0m"
# for client in $ALL_CLIENTS
# do
#     echo -e "\033[34m ======检查最大打开文件描述符 at $client====== \033[0m"
#     ssh $client "ulimit -n 10000 && echo '成功'"
# done
#以下内容不可以重复执行
echo -e "\033[32m ==========修改系统Linux限制值========== \033[0m"
for client in $ALL_CLIENTS
do
    echo -e "\033[34m ======修改系统Linux限制值 at $client====== \033[0m"
    ssh $client "sed -i '/# End of file/i\*             -    nofile           1000000' /etc/security/limits.conf && sed -i '/# End of file/i\*             -    nproc            1000000' /etc/security/limits.conf"
done
echo -e "\033[32m ==========linux优化:调整内存分配;避免使用swap分区;优化net.core.somaxconn参数========== \033[0m"
for client in $ALL_CLIENTS
do
   echo -e "\033[34m ====== at $client====== \033[0m"
    ssh $client "echo 'vm.swappiness = 1' >> /etc/sysctl.conf && echo 'vm.overcommit_ratio = 95' >> /etc/sysctl.conf && echo 'vm.overcommit_memory = 2' >> /etc/sysctl.conf && echo 'net.core.somaxconn = 2048' >> /etc/sysctl.conf && sysctl -p"
done

echo -e "\033[32m =============安装jdk============== \033[0m"
tar -zxf jdk-8u112-linux-x64.tar.gz -C /opt/
for client in $ALL_CLIENTS
do
    echo -e "\033[34m ======Install JDK at $client====== \033[0m"
    scp -rq /opt/jdk1.8.0_112 root@$client:/opt
    ssh $client "echo 'umask 0022' >> /etc/profile && echo '#java env' >> /etc/profile && echo 'export JAVA_HOME=/opt/jdk1.8.0_112' >> /etc/profile && echo 'export PATH=\$JAVA_HOME/bin:\$PATH' >> /etc/profile && echo 'export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar' >> /etc/profile"
    ssh $client "source /etc/profile && java -version"
done
echo -e "\033[32m =============关闭THP============== \033[0m"
for client in $ALL_CLIENTS
do
    ssh $client "echo 'if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
 echo never > /sys/kernel/mm/transparent_hugepage/enabled
 fi
 if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
 echo never > /sys/kernel/mm/transparent_hugepage/defrag
 fi ' >> /etc/rc.d/rc.local"
done
echo -e "\033[32m =============拷贝ambari.repo============== \033[0m"
for client in $ALL_CLIENTS
do
    echo -e "\033[34m ======拷贝ambari.repo at $client====== \033[0m"
    scp -rq ambari.repo root@$client:/etc/yum.repos.d/
done

