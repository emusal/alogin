#!/bin/bash

# Environments
#
function init_env()
{
	ALOGIN_VERSION="1.7.12b"

	# CONFIGURATION
	#
	ALOGIN_SERVER_LIST=${ALOGIN_ROOT}/server_list
	ALOGIN_GATEWAY_LIST=${ALOGIN_ROOT}/gateway_list
	ALOGIN_ALIAS_HOSTS=${ALOGIN_ROOT}/alias_hosts
	ALOGIN_SPECIAL_HOSTS=${ALOGIN_ROOT}/special_hosts
	ALOGIN_CLUSTERS=${ALOGIN_ROOT}/clusters
	ALOGIN_KEYCHAIN=${ALOGIN_ROOT}/alogin.keychain
	ALOGIN_LOG_FILE=${ALOGIN_ROOT}/alogin.log
	
	if [ -z "${ALOGIN_LOG_LEVEL}" ] ; then
		ALOGIN_LOG_LEVEL=0
	fi
	if [ -z "${ALOGIN_HOST_FILE}" ] ; then
		ALOGIN_HOST_FILE=/etc/hosts
	fi
	if [ -z "${ALOGIN_SPECIAL_TERM_THEME}" ] ; then
		if [ "$TERM_PROGRAM" = "Apple_Terminal" ] ; then
			export ALOGIN_SPECIAL_TERM_THEME="Basic"
		else
			export ALOGIN_SPECIAL_TERM_THEME="cyan"
		fi
	fi
	if [ -z "${ALOGIN_LANG}" ] ; then
		ALOGIN_LANG="ko_KR.eucKR"
	fi

	if [ ! -e "${ALOGIN_LOG_FILE}" ] ; then
		touch ${ALOGIN_LOG_FILE}
	fi
	if [ ! -e "${ALOGIN_SERVER_LIST}" ] ; then
		cp -rfp ${ALOGIN_SERVER_LIST}.example ${ALOGIN_SERVER_LIST}
	fi
	if [ ! -e "${ALOGIN_GATEWAY_LIST}" ] ; then
		cp -rfp ${ALOGIN_GATEWAY_LIST}.example ${ALOGIN_GATEWAY_LIST}
	fi
	if [ ! -e "${ALOGIN_ALIAS_HOSTS}" ] ; then
		cp -rfp ${ALOGIN_ALIAS_HOSTS}.example ${ALOGIN_ALIAS_HOSTS}
	fi
	if [ ! -e "${ALOGIN_SPECIAL_HOSTS}" ] ; then
		cp -rfp ${ALOGIN_SPECIAL_HOSTS}.example ${ALOGIN_SPECIAL_HOSTS}
	fi
	if [ ! -e "${ALOGIN_CLUSTERS}" ] ; then
		cp -rfp ${ALOGIN_CLUSTERS}.example ${ALOGIN_CLUSTERS}
	fi

	# FILE FORMAT
	#
	SVR_FMT="%-7s %-20s %-20s %-20s %-5s %s"
	SVR_FMT_BAR="------- -------------------- -------------------- -------------------- ----- --------------------"
	
	if [ ! -e ${ALOGIN_SERVER_LIST} ] ; then
		printf "${SVR_FMT}\n" "#proto" "host" "user" "passwd" "port" "gateway" > ${ALOGIN_SERVER_LIST}
		echo "#${SVR_FMT_BAR}" >> ${ALOGIN_SERVER_LIST}
	fi

	export MANPATH=$MANPATH:$ALOGIN_ROOT/man
}

# Global Variables
#
function init_global()
{
	g_c_opt="" 		# execute command
	g_p_opt="" 		# put file name
	g_g_opt=""		# get file name
	g_t_opt=""		# tunnenr option
	g_L_opt=""		# tunnel -L option
	g_R_opt=""		# tunnel -R option
	g_s_opt=""		# screen id
	g_x_opt=""		# tile_x
	g_h_opt=""		# help
	g_hosts=""
	g_tty=`tty`
}

function tver()
{
	if [ "$1" == "-v" ] ; then
	echo ""
	echo "- Release Note:"
	echo "  Ver.1.1   <space>, <tab> support                         @ 2011/04/27"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        M   ${ALOGIN_ROOT}/conn.exp"
	echo ""
	echo "  Ver.1.2   "'${ALOGIN_ROOT}'"/clusters support            @ 2011/04/27"
	echo "            password including \"'\" related bug fix"
	echo "            'disdupsvr' added to check duplicated server list"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        M   ${ALOGIN_ROOT}/csshX"
	echo "        A   ${ALOGIN_ROOT}/clusters"
	echo ""
	echo "  Ver.1.3   ALOGIN_HOST_FILE env added (see README.txt)    @ 2011/05/06"
	echo "            Excel passwd file parser added (see flexi/README)"
	echo "            Git support using Dropbox"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/README.txt"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        M   ${ALOGIN_ROOT}/clusters.example"
	echo "        M   ${ALOGIN_ROOT}/conn.exp"
	echo "        A   ${ALOGIN_ROOT}/flexi"
	echo ""
	echo "  Ver.1.4   '-g' option to get a file is implemented      @ 2011/05/11"
	echo "            '-f' option is changed to '-p'"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        M   ${ALOGIN_ROOT}/conn.exp"
	echo ""
	echo "  Ver.1.5   ALOGIN_SSHOPT env added (see README.txt)      @ 2011/05/16"
	echo "            '-t' option is added to make tunnel port"
	echo "            'ttysend' utility is added"
	echo "            'tc' command is added to send command to all terminals"
	echo "            white space with -p/g/c/t options support"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        M   ${ALOGIN_ROOT}/conn.exp"
	echo "        M   ${ALOGIN_ROOT}/README.txt"
	echo "        A   ${ALOGIN_ROOT}/ttysend"
	echo ""
	echo "  Ver.1.5.1  -g/-p/-t option bug patch                    @ 2011/05/18"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo ""
	echo "  Ver.1.5.2  'cr' bug patch                               @ 2011/05/19"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo ""
	echo "  Ver.1.5.3  improving to handle exception case           @ 2011/06/08"
	echo "             Ability to select screen id for launching ct/cr terminals"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo ""
	echo "  Ver.1.6    Special host added                           @ 2011/07/26"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        A   ${ALOGIN_ROOT}/special_hosts.example"
	echo ""
	echo "  Ver.1.6.1  Special host support iTerm                   @ 2011/07/27"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo ""
	echo "  Ver.1.6.2  'ssh' tool added to correctly support SSHOPT @ 2011/08/24"
	echo "             csshX version upgrade"
	echo "             csshx.conf for csshX is added"
	echo "             reconnect and retry input password feature added"
	echo "             -L,-R options for secure tunnel added"
	echo "             'gateway_list' added"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        A   ${ALOGIN_ROOT}/ssh"
	echo "        A   ${ALOGIN_ROOT}/csshx.conf"
	echo ""
	echo "  Ver.1.6.3  cssh for iTerm is added                      @ 2011/11/27"
	echo "             prompt format changed"
	echo "             reconnect mechanism added when timeout"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        M   ${ALOGIN_ROOT}/conn.exp"
	echo "        A   ${ALOGIN_ROOT}/csshX.iterm"
	echo ""
	echo "  Ver.1.6.4  remove limit for reconnect count             @ 2011/12/19"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        M   ${ALOGIN_ROOT}/conn.exp"
	echo ""
	echo "  Ver.1.6.5  remove fake ssh tool ('eval' use)            @ 2012/05/07"
	echo "  ---------------------------------------------------------------------"
	echo "        D   ${ALOGIN_ROOT}/ssh"
	echo "        M   ${ALOGIN_ROOT}/conn.exp"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.exp"
	echo ""
	echo "  Ver.1.7    cygwin with Putty support                    @ 2012/05/22"
	echo "             'addhost' added"
	echo "             's' bug patch"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "  Ver.1.7.1  Empty gateway list support                   @ 2012/07/05"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "  Ver.1.7.2  addhost bug fix                              @ 2012/10/30"
	echo "             'tsend.py' added"
	echo "             'ttysend' removed"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        A   ${ALOGIN_ROOT}/tsend.py"
	echo "        D   ${ALOGIN_ROOT}/ttysend"
	echo "  Ver.1.7.3  alias hosts added                            @ 2013/01/24"
	echo "             'alias_hosts' added"
	echo "  ---------------------------------------------------------------------"
	echo "        A   ${ALOGIN_ROOT}/alias_hosts.example"
	echo "  Ver.1.7.4  xfind_xxx added to support Alfred extention  @ 2013/03/28"
	echo "             answer feature added when remove a file after ftp transfer"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        M   ${ALOGIN_ROOT}/conn.exp"
	echo "  Ver.1.7.5  -x option added to set tile_x when cr/ct     @ 2013/04/19"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "  Ver.1.7.6  findhost and xfindhost added                 @ 2013/05/02"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "  Ver.1.7.7  chgpwd added                                 @ 2013/07/30"
	echo "             improve tsend/trecv feature"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        M   ${ALOGIN_ROOT}/conn.exp"
	echo "        A   ${ALOGIN_ROOT}/trecv.sh"
	echo ""
	echo "  Ver.1.7.8  Add 'm' command to mount sshfs volumes       @ 2013/11/21" 
	echo "             'm' requires to install 'pkgs/osxfuse-2.6.1.dmg' and 'pkgs/SSHFS-2.4.1.pkg' packages."
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        M   ${ALOGIN_ROOT}/conn.exp"
	echo ""
	echo "  Ver.1.7.9  'vagrant' support                            @ 2014/01/16" 
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        M   ${ALOGIN_ROOT}/conn.exp"
	echo "  Ver.1.7.10 auto-completion support                      @ 2014/02/05" 
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "  Ver.1.7.11 auto-completion related bug patch            @ 2014/02/20" 
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        M   ${ALOGIN_ROOT}/conn.exp"
	echo "  Ver.1.7.12 Imporved auto-completion feature             @ 2014/03/13" 
	echo "             Added --left, --right options for alignment of cluster windows (ct/cr)"
	echo "             Added 'runscpt' funciton"
	echo "  ---------------------------------------------------------------------"
	echo "        M   ${ALOGIN_ROOT}/alogin_env.sh"
	echo "        M   ${ALOGIN_ROOT}/csshX"
	fi

	echo "ALOGIN Ver.${ALOGIN_VERSION}"
}

function datestr()
{
	date +"%Y%m%d %H:%M:%S"
}
function log_debug()
{
	if [ $ALOGIN_LOG_LEVEL -ge 2 ] ; then
		local fmt=$1;shift
		printf "$(datestr) [DEBUG] $fmt\n"$* >> ${ALOGIN_LOG_FILE}
	fi
}
function log_info()
{
	if [ $ALOGIN_LOG_LEVEL -ge 1 ] ; then
		local fmt=$1;shift
		printf "$(datestr) [INFO] $fmt\n"$* >> ${ALOGIN_LOG_FILE}
	fi
}
function log_error()
{
	if [ $ALOGIN_LOG_LEVEL -ge 0 ] ; then
		local fmt=$1;shift
		printf "$(datestr) [ERROR] $fmt\n"$* >> ${ALOGIN_LOG_FILE}
	fi
}

# Printing Usage functions
#
function help_t()
{
	echo "usage t: t {account@}[hostname]"
}
function help_r()
{
	echo "usage r: r {account@}[hostname]"
}
function help_ct()
{
	echo "usage ct: ct {account@}[hostname]"
}
function help_cr()
{
	echo "usage cr: cr {account@}[hostname]"
}
function help_f()
{
	echo "usage f: f {account@}[hostname]"
}
function help_s()
{
	echo "usage s: s {account@}[hostname]"
}
function help_tc()
{
	echo ":: TERMINAL COMMAND"
	echo "   usage tc: tc { command }"
}
function help_addsvr()
{
	echo "usage addsvr: addsvr { protocol } { hostname } { username } { password } [ port ] [ gateway ]"
}
function help_dissvr()
{
	echo ":: DISPLAY SERVER INFORMATION"
	echo "   usage dissvr: dissvr {account@}[hostname]"
}
function help_delsvr()
{
	echo ":: DELETE SERVER INFORMATION"
	echo "   usage delsvr: delsvr {account@}[hostname]"
}
function help_chgsvr()
{
	echo ":: CHANGE SERVER INFORMATION"
	echo "   usage chgsvr: chgsvr { protocol } { hostname } { username } { password } [ port ] [ gateway ]"
}
function help_dissrt()
{
	echo ":: DISPLAY SERVER ROUTE"
	echo "   usage dissvr: dissvr {account@}[hostname]"
}
function help_disdupsvr()
{
	echo ":: DISPLAY DUPLICATED SERVER LIST"
	echo "   usage: disdupsvr"
}
function help_addalias()
{
	echo ":: ADD AN ALIAS HOST"
	echo "   usage: addalias [alias-name] {user@}[hostname]"
}
function help_disalias()
{
	echo ":: DISPLAY ALIAS HOST LIST"
	echo "   usage: disalias [alias-name]"
}
function help_chgpwd()
{
	echo ":: CHANGE USER PASSWORD OF ALL OR SPECIFIC HOST"
	echo "   usage: chgpwd [user]{@hostname} [new-password]"
}
function help_IS_SPECIAL_HOST()
{
	echo ":: CHECK WHETHER THIS IS SPECIAL HOST OR NOT"
	echo "   usage: IS_SPECIAL_HOST [hostname]"
}

function function_exists() { $1 > /dev/null 2>&1; }
function thelp()
{
	local funcname="help_"${1}
	if [ "$1" == "" ] ; then 
		echo " Usage: thelp {command}"
		return
	fi
	if function_exists ${funcname} ; then
		$funcname
	else
		echo "${1} : unknown command"
	fi
}
alias print_thelp='thelp ${FUNCNAME[0]}; return'

# input format :
#	"user@host" or "host" only
#
function get_user()
{
	local a=(${1//@/ })
	if [ ! -z ${a[1]} ] ; then
		echo ${a[0]}
	else
		echo ""
	fi
}
function get_default_user()
{
	local user=`get_user $*`
	if [ ! -z "$user" ] ; then
		echo $user
	else
		grep -v "^#" ${ALOGIN_SERVER_LIST} | \
			awk -v h="${host}" '{ if ( $2 == h ) print $3 }' | head -1
	fi
}
function get_host()
{
	local a=(${1//@/ })
	if [ ! -z ${a[1]} ] ; then
		echo ${a[1]}
	else
		echo ${a[0]}
	fi
}
# for normalized input (user@host)
function get_user_n()
{
	local a=(${1//@/ })
	if $(echo "$1" | grep --quiet "@") && [ ! -z ${a[0]} ]; then
		echo ${a[0]}
	else
		echo ""
	fi
}
function get_host_n()
{
	local a=(${1//@/ })
	if [ ! -z ${a[1]} ] ; then
		echo ${a[1]}
	else
		echo ""
	fi
}
function GETPWD()
{
	local user=`get_user ${1}`
	local host=`get_host ${1}`

	if [ -z ${ALOGIN_KEYCHAIN_USE} ] ; then
		pwd=`grep -v "^#" ${ALOGIN_SERVER_LIST} | \
			awk -v h="${host}" -v u="${user}" \
			'{ if ( $2 == h && ( u == "" || u == $3 )  ) print $4 }' | head -1`
	else
		if [ -z "$user" ] ; then
			pwd=`security 2>&1 > /dev/null find-generic-password \
				-gs ${host} ${ALOGIN_KEYCHAIN}	\
				| ruby -e 'print $1 if STDIN.gets =~ /^password: "(.*)"$/'`
		else
			pwd=`security 2>&1 > /dev/null find-generic-password \
				-gs ${host} -a ${user} ${ALOGIN_KEYCHAIN}	\
				| ruby -e 'print $1 if STDIN.gets =~ /^password: "(.*)"$/'`
		fi
		if [ $? -ne 0 ] ; then
			pwd=""
		fi
	fi
	local pwd=`echo "$pwd" | sed "s/<space>/ /g"`
	pwd=`echo "$pwd" | sed "s/<tab>/	/g"`
	echo "$pwd"
}
function sGETPWD()
{
	GETPWD $1 | sed 's/./*/g'
}
function getpwd()
{
	GETPWD ${1} | pbcopy
}
function IP()
{
	local host=`get_host $1`
	local ip=`grep -v ^# ${ALOGIN_HOST_FILE} | grep "^[0-9]" | awk -v h="$host" '{ for(i=2; i<=NF; i++) if ( $i == h ) { print $1 ; exit } }'`
	echo $ip
}
function ip()
{
	local ip=`IP $1`
	echo -n $ip | pbcopy
}
function getopt()
{
	local opt=$1;shift;
	if [ "$opt" = "-c" ] ; then
		g_c_opt="$1"
	elif [ "$opt" = "-p" ] ; then
		g_p_opt="$1"
	elif [ "$opt" = "-g" ] ; then
		g_g_opt="$1"
	elif [ "$opt" = "-t" ] ; then
		g_t_opt="$1"
	elif [ "$opt" = "-L" ] ; then
		g_L_opt="$1"
	elif [ "$opt" = "-R" ] ; then
		g_R_opt="$1"
	elif [ "$opt" = "-s" ] ; then
		g_s_opt="$1"
	elif [ "$opt" = "-x" ] ; then
		g_x_opt="$1"
	elif [ "$opt" = "-LR" ] || [ "$opt" = "-RL" ] ; then
		g_L_opt="$1"
		g_R_opt="$1"
	fi
}
function get_svr()
{
	local user=`get_default_user ${1}`
	local host=`get_host ${1}`

	grep -v "^#" ${ALOGIN_SERVER_LIST} | \
		awk -v h="${host}" -v u="${user}" \
		'{ if ( $2 == h && ( u == "" || u == $3 ) ) { \
		printf $2 ; exit }}' | head -1
}
function get_svr_info()
{
	local user=`get_default_user ${1}`
	local host=`get_host ${1}`
	local pswd=`GETPWD ${1}`

	if [ -z ${pswd} ] ; then 
		pswd=""
	fi

#	grep -v "^#" ${ALOGIN_SERVER_LIST} | \
#		awk -v h="${host}" -v p="$pswd" -v u="${user}" \
#		'{ if ( $2 == h && ( u == "" || u == $3 ) ) \
#		printf "%-10s %-20s %-20s %-20s %-8s\n", $1, $2, $3, p, $5 }' | head -1

	if [ -z ${ALOGIN_KEYCHAIN_USE} ] ; then
		grep -v "^#" ${ALOGIN_SERVER_LIST} | \
			awk -v h="${host}" -v u="${user}" \
			'{ if ( $2 == h && ( u == "" || u == $3 ) ) { \
			printf "%-6s %-20s %-20s %-20s ", $1, $2, $3, $4;exit }}' | head -1
	else
		grep -v "^#" ${ALOGIN_SERVER_LIST} | \
			awk -v h="${host}" -v u="${user}" \
			'{ if ( $2 == h && ( u == "" || u == $3 ) ) { \
			printf "%-6s %-20s %-20s ", $1, $2, $3;exit }}' | head -1
		echo -n $pswd
	fi

	grep -v "^#" ${ALOGIN_SERVER_LIST} | \
		awk -v h="${host}" -v u="${user}" \
		'{ if ( $2 == h && ( u == "" || u == $3 ) ) { \
		printf "%-5s\n", $5 ; exit }}' | head -1
}
function get_alias_host()
{
	local aliasname="$1" host="$2"

	if [ -e ${ALOGIN_ALIAS_HOSTS} ] ; then
		host=`grep -v "^#" ${ALOGIN_ALIAS_HOSTS} | \
			awk -v h="${aliasname}" '{ if ( $1 == h ) print $2}' | head -1`
		if [ -z "${host}" ] ; then host=$2; fi
	fi
	echo ${host}
}
function get_gateway()
{
	local user=""
	local host=`get_alias_host ${1} ${1}`
	user=`get_user ${host}`
	host=`get_host ${host}`

	grep -v "^#" ${ALOGIN_SERVER_LIST} | \
		awk -v h="${host}" -v u="${user}" \
		'{ if ( $2 == h && ( u == "" || u == $3 ) ) \
		printf "%s\n", $6 }' | head -1
}
function get_gateway_list()
{
	local host=$(translate_host $1)
	local gw=`get_gateway ${host}`
	local hosts=""

	if [ -z "${gw}" ] || [ "${gw}" == "-" ] ; then
		echo ${host}
		return
	fi

	if [ -e ${ALOGIN_GATEWAY_LIST} ] ; then
		hosts=`grep -v "^#" ${ALOGIN_GATEWAY_LIST} | \
			awk -v h="${gw}" '{ if ( $1 == h ) print }' | head -1`
		if [ ! -z "${hosts}" ] ; then 
			hosts=`echo ${hosts} | sed "s/${gw}//"`
			echo ${hosts}" " ${1}
			return;
		fi
	fi

	if [ -z "${hosts}" ] ; then
		local gw=${host}
		while [ 1 ] ; do
			gw=`get_gateway ${gw}`
			if [ -z "${gw}" ] || [ "${gw}" = "-" ] ;then break; fi
			hosts=${gw}" "${hosts}
		done
	fi

	echo ${hosts}" "${1}
}

# Management Commands
#
function addsvr()
{
	if [ $# -lt 4 ] ; then print_thelp; fi

	init_global

	local host=$2
	local user=$3
	local port=$5
	local hidden_passwd="_HIDDEN_"
	if [ -z $port ] ; then port="-"; fi
	local gw=$6
	if [ -z $gw ] ; then gw="-"; fi

	local pswd=`GETPWD ${user}@${host}`
	if [ ! -z ${pswd} ] ; then
		echo "${user}@${host} already exist"
		return
	fi

	if [ -z ${ALOGIN_KEYCHAIN_USE} ] ; then
		# proto host user passwd port gw
		printf "${SVR_FMT}\n" $1 $2 $3 $4 $port $gw >> ${ALOGIN_SERVER_LIST}
	else 
		# proto host user passwd port gw
		printf "${SVR_FMT}\n" $1 $2 $3 ${hidden_passwd} $port $gw >> ${ALOGIN_SERVER_LIST}
		security add-generic-password -s ${2} -a ${3} -p ${4} ${ALOGIN_KEYCHAIN}
	fi
}
function dissvr()
{
#	local val=$(translate_host $1)
	local val="${1}"
	local user=`get_user ${val}`
	local host=`get_host ${val}`
	local users=""

	init_global

	printf "${SVR_FMT}\n" "proto" "host" "user" "passwd" "port" "gateway"
	echo "${SVR_FMT_BAR}"

	if [ -z "$user" ] ; then
		users=`grep -v "^#" ${ALOGIN_SERVER_LIST} | awk -v h="${host}" '{ if ( $2 == h ) print $3 }' | uniq`
	else
		users=$user
	fi

	for u in $users ; do
		if [ -z "$2" ] ; then local pswd=`sGETPWD ${u}@${host}`;
		else local pswd=`GETPWD ${u}@${host}`; fi
		if [ -z "${pswd}" ] ; then 
			continue
		fi

		grep -v "^#" ${ALOGIN_SERVER_LIST} | \
			awk -v h="${host}" -v u="${u}" -v p="${pswd}" -v svrfmt="${SVR_FMT}\n" \
			'{ if ( $2 == h && ( u == "" || u == $3 ) ) { \
			printf svrfmt, $1, $2, $3, p, $5, $6 ; exit }}'
	done
}
function delsvr()
{
	local user=`get_user ${1}`
	local host=`get_host ${1}`

	init_global

	if [ ! -z ${ALOGIN_KEYCHAIN_USE} ] ; then
		echo "You have to remove this key from the Keychain."
#security 2>&1 > /dev/null delete-keychain -gs ${host} -a ${user} ${ALOGIN_KEYCHAIN}
	fi

	cat ${ALOGIN_SERVER_LIST} | \
		awk -v h="${host}" -v u="${user}" \
		'{ if ( $2 != h || ( u != "" && u != $3 ) ) print }' > ${ALOGIN_ROOT}/.tmp
	mv ${ALOGIN_ROOT}/.tmp ${ALOGIN_SERVER_LIST}
}
function chgsvr()
{
	local host=$2
	local user=$3
	
	init_global

	delsvr ${user}@${host}
	addsvr $@
}
function dissvrlist()
{
	grep -v "^#" ${ALOGIN_SERVER_LIST} | awk '{ if ( $1 ~ /[a-z]/ ) {printf("%-30s %-20s %-20s\n",$2, $3, $6)} else { if ($0 > 0 ) printf ("\n%s\n"), $0}; }'
}
function dissrt()
{
	local hosts=$(translate_host $1)
	local gw=$hosts

	init_global

	printf "${SVR_FMT}\n" "proto" "host" "user" "passwd" "port" "gateway"
	echo "${SVR_FMT_BAR}"

	hosts=`get_gateway_list ${gw}`

	for host in ${hosts} ; do
		get_svr_info ${host} | tr ":\n" " "
		get_gateway ${host}
#		get_svr_info ${host} 
	done
	echo ""
	echo "ip-address      hostname"
	echo "--------------  --------------------------"
	for host in ${hosts} ; do
		host=`get_host ${host}`
		printf "%-15s %s\n" `IP ${host}` ${host}
	done
}
function dissrt_simple()
{
	local hosts=$1
	local gw=$hosts

	init_global

	printf "%-6s %-20s %-20s\n" "proto" "host" "user"
	echo "------ -------------------- --------------------"

	hosts=`get_gateway_list ${gw}`

	for host in ${hosts} ; do
		get_svr_info ${host} | awk '{ printf "%-6s %-20s %-20s\n", $1, $2, $3 }'
#		get_gateway ${host}
#		get_svr_info ${host} 
	done
	echo ""
	echo "ip-address      hostname"
	echo "--------------  --------------------------"
	for host in ${hosts} ; do
		host=`get_host ${host}`
		printf "%-15s %s\n" `IP ${host}` ${host}
	done
}
function dishost()
{
	grep $1 ${ALOGIN_HOST_FILE} | awk -v ip="$1" '{ if ( $1 == ip ) print $2 }'
}
function addhost()
{
	local host=$1
	local ip=$2
#	if [ $# -ne 2 ] ; then print_thelp; fi
	if [ $# -ne 2 ] ; then 
		echo -n "hostname: ";read host;
		echo -n "ipaddr  : ";read ip;
	fi
	if [ -z "`IP $host`" ] ; then 
		printf "%-15s %s\n" $ip $host >> ${ALOGIN_HOST_FILE}
	fi
}
function disdupsvr()
{
	grep -v "^#"  ${ALOGIN_ROOT}/server_list | awk '{ printf "%s@%s\n", $3, $2 }' | sort | uniq -d
}
function translate_host()
{
#	local host
#
#	host=$(get_alias_host $1)
#	if [ -z "$host" ] ; then host=$(get_svr $1); 
#	else echo $host;return; fi
#
#	if [ -z "$host" ] ; then
#		local a=($(findalias ${1}))
#		if [ "$a" == "" ] || [ ${#a[@]} -eq 0 ] ; then 
#			log_debug "alias name not found for host[$1]. try to find host from server_list ..."
#			a=($(findsvr ${1}))
#		fi
#		host="${a[0]}"
#		host=`get_alias_host ${host} ${host}`
#		log_debug "host[$1] is translated to ${host}"
#	fi
#	echo ${host}
	echo $1
}
function get_conninfo()
{
	local hosts=$*
	for host in $hosts ; do

		host=`translate_host ${host}`
		host=`get_alias_host ${host} ${host}`
		local info_=`get_svr_info ${host}`
		if [ ${#info_} -eq 0 ] ; then
#			echo "no entry in server list. "${host}
			echo ""
			return
		fi

		# change hostname to ip
		local host=`get_host ${host}`
		local ip=`IP ${host}`
		if [ -z ${ip} ] ; then
			ip=$host
		fi
		log_debug "get_conninfo(): before info[$info_]"
		info=$info" "${info_/$host/$ip}
		log_debug "get_conninfo(): after info[$info]"
	done

	echo $info
}

function is_special_host()
{
	local is_special=0

	if [ -e ${ALOGIN_ROOT}/special_hosts ] ; then
		local a=($g_hosts)
		local dest=`get_host ${a[${#a[*]}-1]}`
		for host in `cat ${ALOGIN_ROOT}/special_hosts | grep -v "^#" | awk '{ print $1 }'` ; do
			if [[ $dest =~ $host ]] ; then
				is_special=1
				break
			fi
		done
	fi

	echo $is_special
}
function IS_SPECIAL_HOST()
{
	if [ $# -ne 1 ] ; then print_thelp; fi
	g_hosts="$1"
	if [ `is_special_host` -eq 1 ] ; then
		echo "Yes, '$1' is a special host"
	else
		echo "No, '$1' is not special host"
	fi
}

function set_title()
{
	local argv=($@)
	local title=""
	if [ $# -gt 0 ] ; then title=${argv[`expr $# - 1`]}; fi
	printf "\033]0;${title}\007";
}

function set_theme()
{
	local window_name="${g_tty}_SSH_$$"
	local theme="$1"	# set default if null

	# for Cygwin support
	if [ -z "$TERM_PROGRAM" ] ; then return; fi

	set_title ${window_name}
	if [ "$TERM_PROGRAM" = "Apple_Terminal" ] ; then 
		if [ -z "$theme" ] ; then 
			osascript -e '
			tell application "Terminal"
				set myterm to (first window whose name contains "'$window_name'")
				set current settings of myterm to default settings
			end tell
			'
			set_title ""
		else
			osascript -e '
			tell application "Terminal"
				set myterm to (first window whose name contains "'$window_name'")
				set current settings of myterm to settings set "'"${theme}"'"
			end tell
			'
		fi
	elif [[ "$TERM_PROGRAM" =~ iTerm* ]] ; then 
		local profile="$theme"
		if [ -z "$theme" ] ; then profile="Default"; fi
		echo -e "\033]50;SetProfile=${profile}\a"
	fi
}

function addalias()
{
	if [ $# -ne 2 ] ; then print_thelp; fi
	local name=`get_alias_host $1 $1`
	if [ "$name" == "$1" ] ; then printf "%-16s %s\n" $1 $2 >> $ALOGIN_ALIAS_HOSTS; 
	else log_error "'$1' already exist"; fi
}

function disalias()
{
	if [ $# -ne 1 ] ; then print_thelp; fi
	local name=`get_alias_host $1 $1`
	if [ "$name" == "$1" ] ; then log_error "'$1' not exist"; 
	else echo $name; fi
}

function get_locale()
{
#	local host=$1
#	local locale=""
#	if [ -z "$host" ] ; then
#		locale=${ALOGIN_LANG}
#	else
#		locale="ko_KR.UTF-8"
#		locale="ko_KR.eucKR"
#	fi
#	log_debug "the locale of host[${host}] is $locale"
#	echo "${locale}"
	echo ${ALOGIN_LANG}
}

# telnet or ssh
function t()
{
	if [ $# -eq 0 ] ; then
		if [ ! -z "${ALOGIN_PREFERRED_HOST}" ] ; then
			t ${ALOGIN_PREFERRED_HOST}
		else 
			print_thelp
		fi
		return
	fi

	local info=""
	local is_next_skip=0

	init_global

	for n in "${@}" ; do
		if [[ $n =~ ^-([cpgtshLR]|LR|RL)$ ]] ; then
			getopt "${@}"
			is_next_skip=1
		else
			if [ $is_next_skip -ne 1 ] ; then
				g_hosts=${g_hosts}" "${n}
			fi
			is_next_skip=0
		fi
		shift
	done

	g_hosts="${ALOGIN_DEFAULT_GW} $g_hosts"
	local info=`get_conninfo $g_hosts`
	if [ -z "$info" ] ; then
		echo "no entry server"
		return
	fi

	log_debug "connection info : $info -c "$g_c_opt" -p "$g_p_opt" -g "$g_g_opt" -t "$g_t_opt" -L "${g_L_opt}" -R "${g_R_opt}""


	if [ `is_special_host` -ne 0 ] ; then 
		set_theme "${ALOGIN_SPECIAL_TERM_THEME}"
	elif [ ! -z "${ALOGIN_DEFAULT_TERM_THEME}" ] ; then
		set_theme "${ALOGIN_DEFAULT_TERM_THEME}"
	fi
	if [ `is_special_host` -eq 0 ] ; then set_title ${g_hosts}; fi

	local a=($g_hosts)
	local dest=`get_host ${a[${#a[*]}-1]}`
	LC_ALL=$(get_locale ${dest}) ${ALOGIN_ROOT}/conn.exp $info -c "$g_c_opt" -p "$g_p_opt" -g "$g_g_opt" -t "$g_t_opt" -L "${g_L_opt}" -R "${g_R_opt}"
	set_theme # set default
}

# mount remote volume
function m()
{
	local a=(${1//:/ })
	local ahost=$(get_alias_host ${a[0]} ${a[0]})
	local dest_path=${a[1]}

	a=(${ahost//:/ })
	ahost="${a[0]}"
	if [ -z "${dest_path}" ] ; then 
		dest_path=${a[1]}
	fi
	ahost=$(translate_host ${ahost})

	local host=$(get_host ${ahost})
	local info=`get_svr_info ${ahost} | \
		 awk -v host="$host" '{ if ( $2 == host ) print $2" "$3" "$4" "$5 }'`
#	local ip=`IP ${host}`
#	info=${info/$host/$ip} # converting hostname

	init_global

	if [ ! -e "/usr/local/bin/sshfs" ] ; then
		echo "WARNING: Not supported feature."
		echo "  sshfs is not installed in this system. "
		echo "  m() requires to install sshfs and osxfuse."
		echo "  The pacakges, sshfs and osxfuse, are placed in ALOGIN_ROOT/pkgs"
		return
	fi
	if [ -z "${dest_path}" ] ; then
		dest_path="."
	fi
	log_debug "$info"
	LC_ALL=$(get_locale ${host}) ${ALOGIN_ROOT}/conn.exp sshfs $info -d "${dest_path}"
}

# Automatically connect to remote host after determining gateway
function r()
{
	if [ $# -eq 0 ] ; then
		if [ ! -z "${ALOGIN_PREFERRED_HOST}" ] ; then
			r ${ALOGIN_PREFERRED_HOST}
		else 
			print_thelp
		fi
		return
	fi

	local info=""
	local is_next_skip=0

	init_global

	for n in "${@}" ; do
		if [[ $n =~ ^-([cpgtshLR]|LR|RL)$ ]] ; then
			getopt "${@}"
			is_next_skip=1
		else
			if [ $is_next_skip -ne 1 ] ; then
				g_hosts=${g_hosts}" "${n}
			fi
			is_next_skip=0
		fi
		shift
	done

	local gw="$g_hosts"

	g_hosts=`get_gateway_list ${gw}`
	if [ -z "$g_hosts" ] ; then
		echo "no entry server"
		return
	fi

	local info=`get_conninfo $g_hosts`
	if [ -z "$info" ] ; then
		echo "no entry server"
		return
	fi

	log_debug "connection info : hosts=${g_hosts} info=${info} -c "$g_c_opt" -p "$g_p_opt" -g "$g_g_opt" -t "$g_t_opt" -L "${g_L_opt}" -R "${g_R_opt}"" 

	if [ `is_special_host` -ne 0 ] ; then 
		set_theme "${ALOGIN_SPECIAL_TERM_THEME}"
	elif [ ! -z "${ALOGIN_DEFAULT_TERM_THEME}" ] ; then
		set_theme "${ALOGIN_DEFAULT_TERM_THEME}"
	fi
	if [ `is_special_host` -eq 0 ] ; then set_title ${g_hosts}; fi

	local a=($g_hosts)
	local dest=`get_host ${a[${#a[*]}-1]}`
	LC_ALL=$(get_locale ${dest}) ${ALOGIN_ROOT}/conn.exp ${info} -c "${g_c_opt}" -p "${g_p_opt}" -g "${g_g_opt}" -t "${g_t_opt}" -L "${g_L_opt}" -R "${g_R_opt}"
	set_theme # set default
}

# ftp
function f()
{
	local ahost=$(get_alias_host ${1} ${1})
	local host=`get_host ${ahost}`
	local info=`get_svr_info ${ahost} | \
		awk -v host="$host" '{ if ( $2 == host ) print $2" "$3" "$4" "$5 }'`

	init_global

	if [ $? -ne 0 ] ; then
		ftp $host
	else
		LC_ALL=$(get_locale ${host}) ${ALOGIN_ROOT}/conn.exp ftp $info 
	fi
}

# secure ftp
function s()
{
	local ahost=$(get_alias_host ${1} ${1})
	local host=`get_host ${ahost}`
	local info=`get_svr_info ${ahost} | \
		 awk -v host="$host" '{ if ( $2 == host ) print $2" "$3" "$4" "$5 }'`
	local ip=`IP ${host}`
	info=${info/$host/$ip} # converting hostname

	init_global

	if [ $? -ne 0 ] ; then
		sftp $host
	else
		LC_ALL=$(get_locale ${host}) ${ALOGIN_ROOT}/conn.exp sftp $info 
	fi
}
function translate_cname()
{
	local a=($(findcluster $1))
	if [ "$a" == "" ] || [ ${#a[@]} -eq 0 ] ; then 
		echo ${1}
	else
		log_debug "translate_cname($1) = ${a[@]}"
		echo ${a[0]}
	fi
}
function cluster_conn()
{
	local cmd=$1;shift 1
	local is_next_skip=0
	local csshX="${ALOGIN_ROOT}/csshX"
	local args=""

	init_global

	for n in "${@}" ; do
		if [ "$n" = "-s" ] ; then
			getopt "${@}"
			args=${args}"--screen=${g_s_opt} "
			is_next_skip=1
		elif [ "$n" = "-x" ] ; then
			getopt "${@}"
			args=${args}"--tile_x=${g_x_opt} "
			is_next_skip=1
		elif [ "$n" = "--left" ] ; then
			getopt "${@}"
			args=${args}"--align=1 "
		elif [ "$n" = "--right" ] ; then
			getopt "${@}"
			args=${args}"--align=2 "
		else
			local an=$(translate_cname $n)
			if [ $is_next_skip -ne 1 ] ; then
				g_hosts=${g_hosts}" "${an}
			fi
			is_next_skip=0
		fi
		shift
	done

#	if [[ $TERM_PROGRAM =~ iTerm* ]] ; then csshX=${csshX}.iterm; fi

	eval ${csshX} --config ${ALOGIN_ROOT}/csshx.conf --ssh="${ALOGIN_ROOT}/alogin_env.sh" --ssh_args="${cmd}" ${g_hosts} ${args} 
}

# cluster t
function ct()
{
	cluster_conn "t" $*
}
# cluster r
function cr()
{
	cluster_conn "r" $*
}
function tc()
{
	local mytty=`tty`
	local allttys=`ps | grep bash | grep -v "grep" | awk '{ print $2 }'`
	local command=${1}

	init_global

	for n in  $allttys ; do 
		local dev="/dev/${n}"
		if [ ${dev} != ${mytty} ] ; then 
			echo ${command} | sudo python ${ALOGIN_ROOT}/tsend.py ${dev};
		fi
	done
}

function timer()
{
	if [[ $# -eq 0 ]]; then
		echo $(date '+%s')
	else
		local  stime=$1
		etime=$(date '+%s')

		if [[ -z "$stime" ]]; then stime=$etime; fi

		dt=$((etime - stime))
		ds=$((dt % 60))
		dm=$(((dt / 60) % 60))
		dh=$((dt / 3600))
		printf '%d:%02d:%02d' $dh $dm $ds
	fi
}

function tsend()
{
	local file=$1
	local tty=$2
	local nbytes=$3
	if [ $# -lt 2 ] ; then
		echo "Usage: tsend {file-name} {tty-name} [bytes_per_line]"
		return
	fi

	if [ -z "$nbytes" ] ; then
		nbytes=32
	fi

	local tmr=$(timer)
	echo $file | sudo python ${ALOGIN_ROOT}/tsend.py /dev/${tty}
	od -vt x1 ${file} | awk -v nbytes=${nbytes} \
		'BEGIN {cnt=0} { \
			for(i=2;i<=NF;i++) {printf "%s%s", $i, ((cnt++%nbytes)==0)?"\n":""} \
		}' \
		| sudo python ${ALOGIN_ROOT}/tsend.py /dev/${tty}
	printf "\4\4" | sudo python ${ALOGIN_ROOT}/tsend.py /dev/${tty}
	echo "Elapsed time: "$(timer $tmr)
}

function trecv()
{
	${ALOGIN_ROOT}/trecv.sh
}

function TRECV() 
{
	cat ${ALOGIN_ROOT}/trecv.sh | pbcopy
}

function ffindsvr()
{
	local user=`get_user_n ${1}`
	local host=`get_host_n ${1}`
	local users=""

	init_global

	printf "${SVR_FMT}\n" "proto" "host" "user" "passwd" "port" "gateway"
	echo "${SVR_FMT_BAR}"

	if [ -z "$user" ] ; then
		grep -v "^#" ${ALOGIN_SERVER_LIST} | awk -v i="${1}" -v svrfmt="${SVR_FMT}\n" \
			'{ if ( $2 ~ i || $3 ~ i ) { \
			printf svrfmt, $1, $2, $3, $4, $5, $6 }}'
	else
		if [ -z "$host" ] ; then
			grep -v "^#" ${ALOGIN_SERVER_LIST} | awk -v u="${user}" -v svrfmt="${SVR_FMT}\n" \
				'{ if ( $3 == u ) { \
				printf svrfmt, $1, $2, $3, $4, $5, $6 }}'
		else
			grep -v "^#" ${ALOGIN_SERVER_LIST} | awk -v u="${user}" -v h="${host}" -v svrfmt="${SVR_FMT}\n" \
				'{ if ( $3 == u && $2 ~ h ) { \
				printf svrfmt, $1, $2, $3, $4, $5, $6 }}'
		fi
	fi
}
function findalias()
{
	grep -v "^#" ${ALOGIN_ALIAS_HOSTS} | awk -v i="${1}" '{ if ( $1 ~ i ) { printf "%s ", $1 }}'
}
function findsvr()
{
	local user=`get_user_n ${1}`
	local host=`get_host_n ${1}`
	local lineend="$2"
	local users=""

	init_global

	if [ -z "$user" ] ; then
		grep -v "^#" ${ALOGIN_SERVER_LIST} | awk -v i="${1}" \
			'{ if ( $2 ~ i || $3 ~ i ) { printf "%s@%s ", $3, $2 }}'
	else
		if [ -z "$host" ] ; then
			grep -v "^#" ${ALOGIN_SERVER_LIST} | awk -v u="${user}" \
				'{ if ( $3 == u ) { printf "%s@%s ", $3, $2 }}'
		else
			grep -v "^#" ${ALOGIN_SERVER_LIST} | awk -v u="${user}" -v h="${host}" \
				'{ if ( $3 == u && $2 ~ h ) { printf "%s@%s ", $3, $2 }}'
		fi
	fi
}
function display_alias()
{
	init_global
	#tput setaf 1
	grep -v "^#" ${ALOGIN_ALIAS_HOSTS} | awk -v i="${1}" '{ if ( $1 ~ i ) { printf "@%s --> %s\n", $1, $2 }}' | sed 's/^/   /g'
	#tput sgr0
}
function display_server()
{
	local start=1
	if [ ! -z "$2" ] ; then start=$2; fi
	init_global
	#tput setaf 2
	(findsvr $1 | sed 's/\ /\\\\n/g' | xargs printf) | sed 's/^/   /g'
	#tput sgr0
}
function display_cluster()
{
	local cnames=$(findcluster $1)

	#tput setaf 6
	if [ ${#cnames[@]} -ne 0 ] ; then
		for cname in ${cnames[@]} ; do
			local i=1
			local a=($(grep -v "^#" ${ALOGIN_ROOT}/clusters | awk -v n="${cname}" '{ if ( $1 ~ n ) { print }}'))
			if [ "$a" == "" ] || [ ${#a[@]} -ne 0 ] ; then
# 				show cluster name only
#				echo "   ${a[0]}"
# 				show member hosts
				echo -n "   ${a[0]} = { "
				while [ $i -lt ${#a[@]} ] ; do
					echo -n "${a[$i]} "
					let i=$i+1
				done
				echo "}"
			fi
		done
	fi
	#tput sgr0
}
function findcluster()
{
	grep -v "^#" ${ALOGIN_ROOT}/clusters | awk -v n="${1}" '{ if ( $1 ~ n ) { printf "%s ", $1 }}'
#	local cnames=($(grep -v "^#" ${ALOGIN_ROOT}/clusters | awk -v n="${1}" '{ if ( $1 ~ n ) { print $1 }}'))
#	if [ ${#cnames[@]} -ne 0 ] ; then
#		for cname in ${cnames[@]} ; do
#			echo $cname
#		done
#	fi
}
function ffindhost()
{
	local ip=${1}
	local fmt="%s %s"

	init_global

	grep -v "^#" ${ALOGIN_HOST_FILE} | awk -v i="${1}" -v fmt="${fmt}\n" \
		'{ if ( $1 ~ i || $2 ~ i ) { printf fmt, $1, $2 }}'
}
function xfindsvr_s()
{
	local user=`get_user_n ${1}`
	local host=`get_host_n ${1}`
	local xmlfmt='<item uid="%s@%s" arg="%s %s@%s">\n<title>%s@%s</title>\n<icon type="fileicon">/Applications/Utilities/Terminal.app</icon>\n</item>\n'

	init_global

	ffindsvr ${1} | tail +3 | awk -v c="${ALOGIN_ARG1}" -v xmlfmt="${xmlfmt}\n" \
				'BEGIN {print "<items>\n"} \
				{printf xmlfmt, $3, $2, c, $3, $2, $3, $2 } \
				END {print "</items>\n"}'
}
function xfindsvr()
{
	local user=`get_user_n ${1}`
	local host=`get_host_n ${1}`
	local xmlfmt='<item uid="%s@%s" arg="%s %s@%s">\n<title>%s@%s</title>\n<icon type="fileicon">/Applications/Utilities/Terminal.app</icon>\n</item>\n'

	init_global

	local i=0
	local svrlist
	local tmplist
	local result=".__result_file.${RANDOM}"

	for arg in $* ; do
		cp /dev/null ${result}
		if [ $i -gt 0 ] ; then
			tmplist=".__server_list.${RANDOM}"
			(ALOGIN_SERVER_LIST=$svrlist;ffindsvr ${arg} > $tmplist;rm $svrlist)
			cat $tmplist | tail +3 | awk -v c="${ALOGIN_ARG1}" -v xmlfmt="${xmlfmt}\n" \
				'BEGIN {print "<items>\n"} \
				{printf xmlfmt, $3, $2, c, $3, $2, $3, $2 } \
				END {print "</items>\n"}' > ${result}
			svrlist=$tmplist
		else
			svrlist=".__server_list.${RANDOM}"
			ffindsvr ${arg} > $svrlist
			cat $svrlist | tail +3 | awk -v c="${ALOGIN_ARG1}" -v xmlfmt="${xmlfmt}\n" \
				'BEGIN {print "<items>\n"} \
				{printf xmlfmt, $3, $2, c, $3, $2, $3, $2 } \
				END {print "</items>\n"}' > ${result}
		fi
		let i=$i+1
	done

	cat $result
	rm -rf $result $svrlist
}
function xfindcluster()
{
	local xmlfmt='<item uid="%s" arg="%s %s">\n<title>%s</title>\n<icon type="fileicon">/Applications/Utilities/Terminal.app</icon>\n</item>\n'
	init_global

	echo "<items>"

	grep -v "^#" ${ALOGIN_ROOT}/clusters | awk -v n="${1}" -v c="${ALOGIN_ARG1}" -v svrfmt="${xmlfmt}\n" \
		'{ if ( $1 ~ n ) { \
		printf svrfmt, $1, c, $1, $1 }}'

	echo "</items>"
}
function xfindhost()
{
	local ip=${1}
	local xmlfmt='<item uid="%s@%s" arg="%s">\n<title>%s : %s</title>\n<icon type="fileicon">/Applications/Utilities/Terminal.app</icon>\n</item>\n'

	init_global

	echo "<items>"
	ffindhost ${ip} | awk -v xmlfmt="${xmlfmt}\n" '{printf xmlfmt, $1, $2, $2, $2, $1 '}
	echo "</items>"

#	ffindhost ${ip} | awk -v xmlfmt="${xmlfmt}\n" \
#				'BEGIN {print "<items>\n"} \
#				{printf xmlfmt, $1, $2, $2, $1, $2 } \
#				END {print "</items>\n"}'
}

function chgpwd()
{
	local user=`get_user ${1}`
	local host=`get_host ${1}`
	local passwd=${2}
	local backup="${ALOGIN_SERVER_LIST}.backup.$(date +%Y%m%d_%H:%M:%S)"

	if [ $# -ne 2 ] ; then print_thelp; fi

	mv ${ALOGIN_SERVER_LIST} ${backup}
	touch ${ALOGIN_SERVER_LIST}

	if [ -z "${user}" ] ; then user=$host;host=""; fi

	while read line ; do
		local params=(${line})
		local len=`expr ${#line}`
		if [ ${len} -eq 0 ] || [ ${line:0:1} = '#' ] ; then
			echo "${line}" >> ${ALOGIN_SERVER_LIST}
			continue
		fi
		if [[ ! -z "${host}" && "${host}" != "${params[1]}" ]] || [ "${user}" != "${params[2]}" ] ; then 
			printf "${SVR_FMT}\n" ${line} >> ${ALOGIN_SERVER_LIST}
			continue
		fi
		printf "${SVR_FMT}\n" ${params[0]} ${params[1]} ${params[2]} ${passwd} ${params[4]} ${params[5]} >> ${ALOGIN_SERVER_LIST}
	done < ${backup}
}

function runscpt() 
{
	local starttty=$1
	local scptfile=$2

	if [ $# -ne 2 ] ; then echo "runscpt [start-tty-num] [source-shell-file]";return; fi
	if [ ! -e "${scptfile}" ] ; then echo "${scptfile} not found";return; fi

	source ${scptfile}

	for i in {0..100} ; do
		local ttyname=$(printf "ttys%03d" $(expr $i + $starttty))
		local funcname="runcmd_term${i}"
		if function_exists ${funcname} ; then
			for j in {0..100} ; do
				local command=$($funcname $j)
				if [ ! -z "${command}" ] ; then 
					echo ${command} | sudo python ${ALOGIN_ROOT}/tsend.py /dev/${ttyname};
					sleep 1
				else
					break
				fi
			done
		else
			break
		fi
	done
}
function _alogin_complete_()
{
	local cmd="${1##*/}"
	local word=${COMP_WORDS[COMP_CWORD]}
	local line=${COMP_LINE}
	local xpat="";

	echo ""
	if [ -z "$word" ] ; then
		thelp $cmd
		echo -n ">> "$line
		return
	else
		# Check to see what command is being executed.
		case "$cmd" in
		[trsfm])
			display_alias "$word" 
			display_server "$word"
			;;
		dissrt)
			display_alias "$word" 
			display_server "$word"
			;;
		dissvr)
			display_server "$word"
			;;
		c[tr])
			display_cluster "$word"
			display_alias "$word" 
			display_server "$word"
			;;
		*)
			;;
		esac
	fi

	COMPREPLY=($(compgen -W "$xpat"))
	prompt_command

	return 0
}

function _alogin_complete2_()
{
	local cmd="${1##*/}"
	local word=${COMP_WORDS[COMP_CWORD]}
	local line=${COMP_LINE}
	local xpat="";

	echo ""
	if [ -z "$word" ] ; then
		thelp $cmd
		echo -n ">> "$line
		return
	else
		# Check to see what command is being executed.
		case "$cmd" in
		[trsfm])
			xpat=${xpat}$(findalias $word)
			xpat=${xpat}$(findsvr $word)
			;;
		dissrt)
			xpat=${xpat}$(findalias $word)
			xpat=${xpat}$(findsvr $word)
			;;
		dissvr)
			xpat=${xpat}$(findsvr $word)
			;;
		c[tr])
			xpat=${xpat}$(findcluster $word)
			xpat=${xpat}$(findalias $word)
			xpat=${xpat}$(findsvr $word)
		;;
		*)
		;;
		esac
	fi

	COMPREPLY=($(compgen -W "$xpat" --))
	prompt_command

	return 0
}

function signal_handler()
{
	return
}

function _alogin_complete3_()
{
	local cmd="${1##*/}"
	local word=${COMP_WORDS[COMP_CWORD]}
	local lwords=(${COMP_LINE})
	local lword=${lwords[COMP_CWORD-1]}
	local line=${COMP_LINE}
	local xpat="";
	local dispstr="";

	echo ""
	if [ -z "$word" ] ; then
		if [ $COMP_CWORD -lt 2 ] ; then
			thelp $cmd
		else
			echo -n ">> ${line}"
			return
		fi
		return
	fi

	# Check to see what command is being executed.
	case "$cmd" in
	[trsfm])
		dispstr=$(display_alias "$word" && display_server "$word")
		echo "$dispstr" | grep -n ^" "
		xpat=${xpat}$(findalias $word)
		xpat=${xpat}$(findsvr $word)
		;;
	dissrt)
		dispstr=$(display_alias "$word" && display_server "$word")
		echo "$dispstr" | grep -n ^" "
		xpat=${xpat}$(findalias $word)
		xpat=${xpat}$(findsvr $word)
		;;
	dissvr)
		dispstr=$(display_server "$word")
		echo "$dispstr" | grep -n ^" "
		xpat=${xpat}$(findsvr $word)
		;;
	c[tr])
		dispstr=$(display_cluster "$word" && display_alias "$word" && display_server "$word")
		echo "$dispstr" | grep -n ^" "
		xpat=${xpat}$(findcluster $word)
		xpat=${xpat}$(findalias $word)
		xpat=${xpat}$(findsvr $word)
	;;
	*)
	;;
	esac

	local i=0
	local cmdlist=($xpat)

	echo ""
	if [ ${#cmdlist[@]} -le 1 ] ; then
		echo -ne "\r\033[K>> ${line}"
		COMPREPLY=($(compgen -W "${cmdlist[0]}" --))
		return
	fi

	echo "${#cmdlist[@]} hosts are matched"
	tput setab 7;tput setaf 4
	echo "[j]:down [k]:up <Tab/Enter>:completion <Delete>:exit"
	tput sgr0

	echo -ne "\r\033[K[$(expr $i + 1)]: ${cmdlist[$i]}"

	trap signal_handler SIGINT

	while [ "$n" != finish ] ; do
		read -d "\ " -s -n 1 n
		case "$n" in
		j)
			if [ $i -le 0 ] ; then let i=${#cmdlist[@]}-1; 
			else let i=$i-1; fi
			;;
		k)
			if [ $i -ge $(expr ${#cmdlist[@]} - 1) ] ; then i=0;
			else let i=$i+1; fi
			;;
		)
			echo -ne "\r\033[K>> ${line}"
			break
			;;
		*)
			COMPREPLY=($(compgen -W "${cmdlist[$i]}" -- ))
			echo -ne "\r\033[K>> ${line}"
			break
			;;
		esac
		echo -ne "\r\033[K[$(expr $i + 1)]: ${cmdlist[$i]}"
	done

	trap - SIGINT

	return
}

# Complete ssh and scp
_ssh()
{
	local cur opts

	# the current partially completed word
	cur="${COMP_WORDS[COMP_CWORD]}"
	# the list of possible options - what we have found reading known_hosts
	opts=$(sed '{ s/^\([^ ]*\) .*$/\1/; s/^\(.*\),.*$/\1/; }' $HOME/.ssh/known_hosts)
	# return the possible completions as a list
	COMPREPLY=($(compgen -W "${opts}" ${cur}))
}


function prompt_command 
{
	echo -e ""
	echo -n ">> "$COMP_LINE
}
#export PROMPT_COMMAND=prompt_command

init_env $*
if [ $# -ne 0 ] ; then 
	cmd=$1;shift;
	${cmd} $*
else
	#shopt -u hostcomplete && complete -F _ssh ssh
	shopt -u hostcomplete 
	complete -F _alogin_complete3_ t r ct cr s f m dissrt dissvr
fi


