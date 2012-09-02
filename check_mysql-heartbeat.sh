#!/bin/sh
# License: GPL v2
# Author: Elan Ruusamäe <glen@delfi.ee>
#
# Usage: check_mysql-heartbeat
#

PROGRAM=${0##*/}
REVISION=$(echo '$Revision$' | sed -e 's/[^0-9.]//g')
PROGPATH=${0%/*}
. $PROGPATH/utils.sh

heartbeat=mk-heartbeat
hostname=
port=
username=
password=
database=
warning=200
critical=400

die() {
	eval local rc=\$STATE_$1
	[ "$rc" ] || rc=$STATE_UNKNOWN
	echo "$1: $2"
	exit $rc
}

usage() {
	cat >&2 <<EOF
Usage: check_mysql-heartbeat

    --mk, --maatkit
       Uses maatkit: mk-heartbeat
    --pt, --percona-toolkit
       Uses percona-toolkit: pt-hearbeat

    -w SECONDS, --warning SECONDS
    -c SECONDS,--critical SECONDS
    -H HOSTNAME, --host HOSTNAME
    -P PORT, --port PORT
    -u USERNAME, --username USERNAME
    -p PASSWORD, --password PASSWORD
    -D DATABASE, --database DATABASE
EOF
}

# Parse arguments
args=$(getopt -o hVw:c:H:P:u:p:D: --long help,version,warning:,critical:,mk,maatkit,pt,percona-tookit,host:,port:,username:,password:,database: -u -n $PROGRAM -- "$@")
if [ $? != 0 ]; then
	usage
	exit 1
fi
eval set -- "$args"

## Start of main program ##
while :; do
	case "$1" in
	-h|--help)
		usage
		exit 0
		;;
	-V|--version)
		echo $PROGRAM $REVISION
		exit 0
		;;
	--mk|--maatkit)
		heartbeat=mk-heartbeat
		;;
	--pt|--percona-toolkit)
		heartbeat=mk-heartbeat
		;;
	-c|--critical)
		shift
		critical=$1
		;;
	-w|--warning)
		shift
		warning=$1
		;;
	-H|--host)
		shift
		hostname=$1
		;;
	-P|--port)
		shift
		port=$1
		;;
	-u|--username)
		shift
		username=$1
		;;
	-p|--password)
		shift
		password=$1
		;;
	-D|--database)
		shift
		database=$1
		;;
	--)
		shift
		break
		;;
	*)
		die UNKNOWN "Internal error: [$1] Not recognized!"
		;;
	esac
	shift
done

if [ -z "$hostname" ]; then
	die UNKNOWN "No hostname given"
fi

# check out config errors
if [ $warning -gt $critical ]; then
	die UNKNOWN "Warning level bigger than critical level"
fi

secs=$($heartbeat ${database:+-D $database} --check -h $hostname ${username:+-u $username} ${password:+-p $password} 2>&1)
rc=$?
if [ "$rc" != 0 ]; then
	die UNKNOWN "$secs"
fi

[ $secs -gt $critical ] && die CRITICAL "$heartbeat on $hostname $secs seconds over critical treshold $critical seconds"
[ $secs -gt $warning ] && die WARNING "$heartbeat on $hostname $secs seconds over warning treshold $warning seconds"

die OK "$heartbeat on $hostname @$secs seconds"
