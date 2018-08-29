#! /data/data/com.termux/files/usr/bin/bash

ROOT_PATH=""
PULL_ONLY=0
SLEEP=2
COMMENT="phone updates"

while getopts r:p:c:s: option
do
    case "${option}"
    in
        r) ROOT_PATH=${OPTARG};;
        p) PULL_ONLY=${OPTARG};;
        s) SLEEP=${OPTARG};;
        c) COMMENT=${OPTARG};;
    esac
done

sleep "$SLEEP"
           
if [ -z "$ROOT_PATH" ]; then
    "$SHELL" say_error "-r expected"
    exit 1
fi

cd "$ROOT_PATH"
if [ "$?" -gt 0 ]; then
    "$SHELL" say_error "Cannot cd to '$ROOT_PATH'"
    exit 1
fi

if [ "$PULL_ONLY" -eq 0 ]; then
    git add -A -n | grep -q '' >/dev/null 2>&1
    if [ "$?" -eq 0 ]; then
        git add --ignore-removal .
        git commit -m "$COMMENT"
        if [ "$?" -gt 0 ]; then
            "$SHELL" say_error "Cannot commit"
            exit 1
        fi
    fi
fi
    
git pull
if [ "$?" -gt 0 ]; then
    "$SHELL" say_error "Cannot pull"
    exit 1
fi

if [ "$PULL_ONLY" -eq 0 ]; then
    git push
    if [ "$?" -gt 0 ]; then
        "$SHELL" say_error "Cannot push"
        exit 1
    fi
fi

command -v am \
    && am broadcast -a com.orgzly.intent.action.SYNC_START com.orgzly/.android.ActionReceiver

"$SHELL" say_ok
exit 0