#! /bin/bash
ssh-keygen -t rsa
ALL_CLIENTS=`cat /etc/hosts| grep "192.168.101" | awk '{print $2}'` 
CLIENTS=""
for client in $ALL_CLIENTS
do
echo "=============copy-ssh-id $client============="
ssh-copy-id $client
done

