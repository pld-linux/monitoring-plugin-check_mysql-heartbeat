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

die() {
	eval local rc=\$STATE_$1
	[ "$rc" ] || rc=$STATE_UNKNOWN
	echo "$2"
	exit $rc
}

usage() {
	cat >&2 <<EOF
Usage: check_mysql-heartbeat

    --mk | --maatkit
       Uses maatkit: mk-heartbeat
    --pt | --percona-toolkit
       Uses percona-toolkit: pt-hearbeat
EOF
}

## Start of main program ##
while [ $# -gt 0 ]; do
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
	esac
	shift
done

if [ -z "$hostname" ]; then
	die UNKNOWN "No hostname given"
fi

out=$($heartbeat ${database:+-D $database} --check -h $hostname ${username:+-u $username} ${password:+-p $password} 2>&1)
rc=$?
if [ "$rc" != 0 ]; then
	die UNKNOWN "$out"
fi
die OK "OK $heartbeat on $hostname @$out"
