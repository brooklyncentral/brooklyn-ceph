#!/usr/bin/env bash

AUGEAS_COMMANDS=()

function usage(){
	cat <<EOF

Usage: augtool-helper [options] [augeas commands]

	-l| --lens		The augeas lens to use see http://augeas.net/stock_lenses.html eg Properties.lns
	-f| --file		The file to configure eg /path/to/file.properties

Example: augtool-helper -l Nginx -f /etc/nginx/conf.d/site.cnf "set /files/etc/nginx/conf.d/site.cnf/http/server/listen 80"
EOF
	exit 1
}

while [[ $# -gt 1 ]]; do
	case $1 in
		-l|--lens)
			AUGEAS_LENS="$2"
			shift
		;;
		-f|--file)
			CONFIG_FILE="$2"
			shift
		;;
		*)
		;;
	esac
	shift
done

hash augtool 2>/dev/null || {
	echo "=== Augeas not installed" >&2
}

if [ -z "${AUGEAS_LENS}" ]; then
	echo "=== No Lens supplied" >&2;
	usage
fi
if [ -z "${CONFIG_FILE}" ]; then
	echo "=== No config file supplied" >&2;
	usage
fi

augtool -Ast "${AUGEAS_LENS} incl ${CONFIG_FILE}"