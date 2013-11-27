#!/bin/bash

keychain_path=${ALOGIN_ROOT}/alogin.keychain
path=${ALOGIN_ROOT}/server_list
new_server_list=${ALOGIN_ROOT}/server_list.dec

source ${ALOGIN_ROOT}/alogin_env.sh

function decrypt_server()
{
	proto=$1
	host=$2
	user=$3
	passwd=$4
	port=$5
	gateway=$6

	passwd=`GETPWD ${user}@${host}`

	printf "%-10s %-20s %-20s %-20s %-8s %-20s\n" \
		$proto $host $user $passwd $port $gateway >> ${new_server_list}
}

echo "#protocol  host                 user                 passwd               port     gateway             " > ${new_server_list}
echo "#--------- -------------------- -------------------- -------------------- -------- --------------------" >> ${new_server_list}

if [ -f ${path} ] ; then
	while read line ; do
		len=`expr ${#line}`
		if [ ${len} -eq 0 ] || [ ${line:0:1} = '#' ] ; then
			continue
		fi
		decrypt_server ${line}
	done < ${path}
else
	echo "can not open file. "${path}
fi


