#! bin/bash

#需要根据实际情况来修改配置。cluster为集群名字，ip为本地ip。
ip=$(LC_ALL=C ifconfig|grep "inet addr:"|grep -v "127.0.0.1"|cut -d: -f2|awk '{print $1}')
host=$(hostname)
cluster="pdmi" 
jdk="/opt/jdk1.8.0_66"
hdp_url="http://10.2.45.91/HDP/centos6/2.x/updates/2.4.2.0"
hdp_utils_url="http://10.2.45.91/HDP-UTILS-1.1.0.20/repos/centos6"

timeStamp(){	#定义函数
        current=`date "+%Y-%m-%d %H:%M:%S"`     #获取当前时间，例：2015-03-11 12:33:41     
        timeStamp=`date -d "$current" +%s`      #将current转换为时间戳，精确到秒
        currentTimeStamp=$((timeStamp*1000+`date "+%N"`/1000000)) #将current转换为时间戳，>精确到毫秒
}

#yum install ambari-agent
#sed -i -e "s|localhost|host1|"  /etc/ambari-agent/conf/ambari-agent.ini
#sed -i "143c ambari_db_rca_password = config['hostLevelParams']['ambari_db_rca_password']" /var/lib/ambari-agent/cache/stacks/HDP/2.0.6/hooks/before-START/scripts/params.py 
#ambari-agent restart

echo -e "\033[34m =================配置本地源===================== \033[0m"
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"Repositories":{"base_url":"'$hdp_url'","verify_base_url":true}}' http://$ip:8080/api/v1/stacks/HDP/versions/2.4/operating_systems/redhat6/repositories/HDP-2.4
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"Repositories":{"base_url":"'$hdp_utils_url'","verify_base_url":true}}' http://$ip:8080/api/v1/stacks/HDP/versions/2.4/operating_systems/redhat6/repositories/HDP-UTILS-1.1.0.20

echo -e "\033[34m =================检查主机===================== \033[0m"
curl -u admin:admin -H "X-Requested-By: ambari" -X GET http://$ip:8080/api/v1/hosts?fields=Hosts/host_status&_=1484192609578

echo -e "\033[34m =================检查主机配置===================== \033[0m"
curl -u admin:admin -H "X-Requested-By: ambari" -X POST -d '{"RequestInfo":{"action":"check_host","context":"Check host","parameters":{"check_execute_list":"host_resolution_check","jdk_location":"http://'$host':8080/resources/","threshold":"20","hosts":"'$host'"}},"Requests/resource_filters":[{"hosts":"'$host'"}]}' http://$ip:8080/api/v1/requests
curl -u admin:admin -H "X-Requested-By: ambari" -X POST -d '{"RequestInfo":{"context":"Check hosts","action":"check_host","parameters":{"threshold":"60","java_home":"'$jdk'","jdk_location":"http://'$host':8080/resources/","check_execute_list":"java_home_check"}},"Requests/resource_filters":[{"hosts":"'$host'"}]}' http://$ip:8080/api/v1/requests

echo -e "\033[34m =================创建集群名字===================== \033[0m"
curl -u admin:admin -H "X-Requested-By: ambari" -X POST -d '{"Clusters":{"version":"HDP-2.4"}}' http://$ip:8080/api/v1/clusters/$cluster

echo -e "\033[34m =================创建服务名字：FLUME===================== \033[0m"
curl -u admin:admin -H "X-Requested-By: ambari" -X POST -d '[{"ServiceInfo":{"service_name":"FLUME"}}]' http://$ip:8080/api/v1/clusters/$cluster/services

echo -e "\033[34m =================提交配置文件===================== \033[0m"
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '[{"Clusters":{"desired_config":[{"type":"flume-conf","tag":"version1","properties":{"content":"\n# Flume agent config"},"service_config_version_note":"Initial configurations for Flume"},{"type":"flume-env","tag":"version1","properties":{"content":"\n# Licensed to the Apache Software Foundation (ASF) under one or more\n# contributor license agreements.  See the NOTICE file distributed with\n# this work for additional information regarding copyright ownership.\n# The ASF licenses this file to You under the Apache License, Version 2.0\n# (the \"License\"); you may not use this file except in compliance with\n# the License.  You may obtain a copy of the License at\n#\n#     http://www.apache.org/licenses/LICENSE-2.0\n#\n# Unless required by applicable law or agreed to in writing, software\n# distributed under the License is distributed on an \"AS IS\" BASIS,\n# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n# See the License for the specific language governing permissions and\n# limitations under the License.\n\n# If this file is placed at FLUME_CONF_DIR/flume-env.sh, it will be sourced\n# during Flume startup.\n\n# Enviroment variables can be set here.\n\nexport JAVA_HOME={{java_home}}\n\n# Give Flume more memory and pre-allocate, enable remote monitoring via JMX\n# export JAVA_OPTS=\"-Xms100m -Xmx2000m -Dcom.sun.management.jmxremote\"\n\n# Note that the Flume conf directory is always included in the classpath.\n# Add flume sink to classpath\nif [ -e \"/usr/lib/flume/lib/ambari-metrics-flume-sink.jar\" ]; then\n  export FLUME_CLASSPATH=$FLUME_CLASSPATH:/usr/lib/flume/lib/ambari-metrics-flume-sink.jar\nfi\n\nexport HIVE_HOME={{flume_hive_home}}\nexport HCAT_HOME={{flume_hcat_home}}","flume_conf_dir":"/etc/flume/conf","flume_log_dir":"/var/log/flume","flume_run_dir":"/var/run/flume","flume_user":"flume"},"service_config_version_note":"Initial configurations for Flume"}]}},{"Clusters":{"desired_config":[{"type":"cluster-env","tag":"version1","properties":{"fetch_nonlocal_groups":"true","ignore_groupsusers_create":"false","kerberos_domain":"EXAMPLE.COM","override_uid":"true","repo_suse_rhel_template":"[{{repo_id}}]\nname={{repo_id}}\n{% if mirror_list %}mirrorlist={{mirror_list}}{% else %}baseurl={{base_url}}{% endif %}\n\npath=/\nenabled=1\ngpgcheck=0","repo_ubuntu_template":"{{package_type}} {{base_url}} {{components}}","security_enabled":"false","smokeuser":"ambari-qa","smokeuser_keytab":"/etc/security/keytabs/smokeuser.headless.keytab","user_group":"hadoop"}}]}}]' http://$ip:8080/api/v1/clusters/$cluster

echo -e "\033[34m =================创建组件名称：FLUME_HANDLER===================== \033[0m"
curl -u admin:admin -H "X-Requested-By: ambari" -X POST -d    '{"components":[{"ServiceComponentInfo":{"component_name":"FLUME_HANDLER"}}]}' http://$ip:8080/api/v1/clusters/$cluster/services?ServiceInfo/service_name=FLUME

echo -e "\033[34m =================确定主机===================== \033[0m"
curl -u admin:admin -H "X-Requested-By: ambari" -X POST -d '[{"Hosts":{"host_name":"'$host'"}}]' http://$ip:8080/api/v1/clusters/$cluster/hosts
curl -u admin:admin -H "X-Requested-By: ambari" -X POST -d '{"RequestInfo":{"query":"Hosts/host_name='$host'"},"Body":{"host_components":[{"HostRoles":{"component_name":"FLUME_HANDLER"}}]}}' http://$ip:8080/api/v1/clusters/$cluster/hosts

echo -e "\033[34m =================安装服务，请稍等===================== \033[0m"
curl -u admin:admin -H "X-Requested-By: ambari" -H "Authorization:Basic YWRtaW46YWRtaW4=" -X PUT -d '{"RequestInfo":{"context":"Install Services","operation_level":{"level":"CLUSTER","cluster_name":"'$cluster'"}},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}' http://$ip:8080/api/v1/clusters/$cluster/services?ServiceInfo/state=INIT

#检查状态，直到为installed时安装完成，执行下一步
timeStamp
until [[ $RESULT =~ "INSTALLED" ]]
do
        sleep 3
        RESULT=$(curl -u admin:admin -H "X-Requested-By: ambari" -X GET http://$ip:8080/api/v1/clusters/$cluster/hosts?fields=Hosts/host_state,host_components/HostRoles/state&_=$currentTimeStamp)
	echo "`date`:正在安装" 
done

timeStamp
echo -e "\033[34m =================检查状态===================== \033[0m"
curl -u admin:admin -H "X-Requested-By: ambari" -X GET http://$ip:8080/api/v1/clusters/$cluster/hosts?fields=Hosts/host_state,host_components/HostRoles/state&_=$currentTimeStamp

echo -e "\033[34m =================启动集群===================== \033[0m"
curl -u admin:admin -H "X-Requested-By: ambari" -X POST -d'{"admin-settings-show-bg-admin":"true"}' http://$ip:8080/api/v1/persist
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"Clusters":{"provisioning_state":"INSTALLED"}}' http://$ip:8080/api/v1/clusters/$cluster
echo -e "\033[34m =================启动服务===================== \033[0m"
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"ServiceInfo": {"state" :"STARTED"}}' http://$ip:8080/api/v1/clusters/$cluster/services/FLUME
