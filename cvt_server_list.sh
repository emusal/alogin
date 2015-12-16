#!/bin/bash

source ${ALOGIN_ROOT}/alogin_env.sh

keychain_path=${ALOGIN_ROOT}/alogin.keychain
path=${ALOGIN_ROOT}/server_list
new_server_list=${ALOGIN_ROOT}/server_list.new

function add_to_keychain()
{
	host=$2
	user=$3
	passwd=$4	
	if [ ! -z ${ALOGIN_KEYCHAIN_USE} ] ; then
		security add-generic-password -s ${host} -a ${user} -p ${passwd} ${keychain_path}
	fi
}
function add_to_serverlist()
{
	proto=$1
	host=$2
	user=$3
	passwd=$4
	port=$5
	gateway=$6
	locale=$7
	if [ -z "$gateway" ] ; then 
		gateway="-"
	fi
	if [ -z "$locale" ] ; then 
		locale="-"
	fi
	if [ -z ${ALOGIN_KEYCHAIN_USE} ] ; then
		printf "${SVR_FMT}\n" \
			$proto $host $user $passwd $port $gateway $locale >> ${new_server_list}
	else
		printf "${SVR_FMT}\n" \
			$proto $host $user "_HIDDEN_" $port $gateway $locale >> ${new_server_list}
	fi
}

if [ ! -z ${ALOGIN_KEYCHAIN_USE} ] ; then
	echo -n "Input Keychain Password: ";read password
	security create-keychain -p ${password} ${keychain_path}
fi

printf "${SVR_FMT}\n" "#proto" "host" "user" "passwd" "port" "gateway" "locale"> ${new_server_list}
printf "#${SVR_FMT_BAR:1}\n" >> ${new_server_list}

if [ -f ${path} ] ; then
	while read line ; do
		len=`expr ${#line}`
		if [ ${len} -eq 0 ] ; then
			echo "" >> ${new_server_list}
			continue
		fi
		if [ ${line:0:1} = '#' ] ; then
			echo "$line" >> ${new_server_list}
			continue
		fi
		add_to_keychain ${line}
		add_to_serverlist ${line}
	done < ${path}
else
	echo "can not open file. "${path}
fi


