#!/usr/bin/env bash
set -e
shopt -s globstar dotglob
index=0
jq_colorize='true'
logerr() { printf '\033[31m%s\033[0m %s: %s\n' 'jqparse' "[$index]" "$*"; }
logok() { printf '\033[32m%s\033[0m %s: %s\n' 'jqparse' "[$index]" "$*"; }
logwarn() { printf '\033[33m%s\033[0m %s: %s\n' 'jqparse' "[$index]" "$*"; }

while [ "$1" ]; do
	case "$1" in
		-o | --output)
			parseintodir="$2"
			unset jq_colorize
			shift
			;;
		-c | --convert)
			tryconvertjson='true'
			;;
		-nc | --no-colors | --no-colours)
			unset jq_colorize
			;;
		-h | --help | --usage)
			printf '%s\n' "Usage: jqparse.sh [options]"
			printf '%s\n' "Options:"
			printf '\t%s\t%s\n' "-o, --output <dir>" "Parse JSON into directory (implies -nc)" 
			printf '\t%s\t\t%s\n' "-c, --convert" "Try to convert invalid JSON into valid JSON"
			printf '\t%s\t%s\n' "-nc, --no-colors" "Disable colors"
			printf '\t%s\t%s\n' "-h, --help, --usage" "Show this help message"
			exit 0
			;;
		*)
			logerr "Unknown argument '$1', use --usage for usage."
			exit 1
			;;
	esac
	shift
done

if [ "$parseintodir" ]; then
	if [ -f "$parseintodir" ]; then
		logerr "'$parseintodir' is a file, unsafe to delete. Aborting."
		exit 1
	fi
	if [ -d "$parseintodir" ]; then
		for i in "$parseintodir/"**; do
			if [[ "$i" != "$parseintodir/"[0-9]*.json ]] && [ "$i" != "$parseintodir/" ]; then
				logerr "Foreign item '$i', unsafe to delete. Aborting."
				exit 1
			fi
		done
	fi
	rm -rf "$parseintodir"
	mkdir -p "$parseintodir"
fi


tryconvertjson() {
	parsed_json=$(printf '%s\n' "$jsonline" | tr \' \" | jq ${jq_colorize:+-C} 2>/dev/null || true)
	if [ "$parsed_json" ]; then
		logwarn "Converted into valid JSON by replacing all single quotes with double quotes, beware of collateral damage."
	fi
}

while IFS= read -r line || [[ -n "$line" ]]; do
    printf '%s\n' "$line"
    rawjson="$(printf '%s\n' "$line" | grep -oP '{(?:[^{}]|(?R))*}' || true)"
    while IFS= read -r jsonline || [[ -n "$jsonline" ]]; do
        parsed_json=$(printf '%s\n' "$jsonline" | jq ${jq_colorize:+-C} 2>/dev/null || true)
		if [ ! "$parsed_json" ] && [ "$tryconvertjson" ]; then
			tryconvertjson
		fi
		if [ "$parsed_json" ] && [ "$parseintodir" ]; then
			printf '%s\n' "$parsed_json" >>"$parseintodir/$index.json"
			logok "Wrote parsed JSON into '$parseintodir/$index.json'"
			index=$((index+1))
		elif [ "$parsed_json" ] && [ ! "$parseintodir" ]; then
			logok "Parsed JSON:"
			printf '%s\n' "$parsed_json"
			index=$((index+1))
		fi
    done <<<"$rawjson"
done </dev/stdin
