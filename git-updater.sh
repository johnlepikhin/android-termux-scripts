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

flock -w30 "$ROOT_PATH/.git/git-updater.lock" "$SHELL" "git-updater-no-lock.sh" $@
exit $?
