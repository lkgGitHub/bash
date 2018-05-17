#! /bin/bash 

echo -e "\033[34m ==========安装nginx============ \033[0m"
yum -y install nginx
ip=$(LC_ALL=C ifconfig|grep "inet addr:"|grep -v "127.0.0.1"|cut -d: -f2|awk '{print $1}')
echo $ip
echo -e "\033[34m ===========修改server-name成功============ \033[0m"
sed -i -e "s|localhost|$ip|" /etc/nginx/conf.d/default.conf && echo "修改server-name成功"


echo -e "\033[34m ===========修改监听的端口号============ \033[0m"
sed -i -e 's/80/9999/' /etc/nginx/conf.d/default.conf && echo "修改监听的端口号成功"

echo -e "\033[34m ===========修改地址============ \033[0m"
sed -i -e '9c root   /usr/bdp/Client/app;' /etc/nginx/conf.d/default.conf && echo "Clent设置完成"

echo -e "\033[34m ====================== \033[0m"
sed -i -e "10a  try_files \$uri \$uri/ /index.html;" /etc/nginx/conf.d/default.conf && echo "添加刷新功能"

service nginx start

