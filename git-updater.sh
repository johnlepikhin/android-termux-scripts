#! /data/data/com.termux/files/usr/bin/bash

while getopts r:p:c:s: option
do
    case "${option}"
    in
        r) ROOT_PATH=${OPTARG};;
    esac
done

if [ -z "$ROOT_PATH" ]; then
    "$SHELL" say_error "-r expected"
    exit 1
fi

FLOCK_FILE="$ROOT_PATH/.git/git-updater.lock"

find "$FLOCK_FILE" -type f -mmin +20 -delete >/dev/null 2>&1

flock -n "$FLOCK_FILE" "$SHELL" "git-updater-no-lock.sh" $@
exit $?
