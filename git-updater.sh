#! /data/data/com.termux/files/usr/bin/bash

ROOT_PATH=""
TOUCH_PATH=""
FORCE=0
PULL_ONLY=0

while getopts r:t:f:p: option
do
    case "${option}"
    in
        r) ROOT_PATH=${OPTARG};;
        t) TOUCH_PATH=${OPTARG};;
        f) FORCE=${OPTARG};;
        p) PULL_ONLY=${OPTARG};;
    esac
done

if [ -z "$ROOT_PATH" ]; then
    say_error "-r expected"
    exit 1
fi

if [ -z "$TOUCH_PATH" ]; then
    say_error "-t expected"
    exit 1
fi

if [ -e "$TOUCH_PATH" ]; then 
    find "$ROOT_PATH" -newer "$TOUCH_PATH" | egrep -q '.*'
    NO_NEW_FILES="$?"
else
    NO_NEW_FILES=0
fi

cd "$ROOT_PATH"
if [ "$?" -gt 0 ]; then
    say_error "Cannot cd to '$ROOT_PATH'"
    exit 1
fi

if [ "$NO_NEW_FILES" -eq 0 ] || [ "$FORCE" -gt 0 ]; then
    git pull
    if [ "$?" -gt 0 ]; then
        say_error "Cannot pull"
        exit 1
    fi
fi

if [ "$NO_NEW_FILES" -eq 0 ] && [ "$PULL_ONLY" -eq 0 ]; then
    git add .
    git commit -a -m 'phone updates'
    git push
    if [ "$?" -gt 0 ]; then
        say_error "Cannot push"
        exit 1
    fi
fi
touch "$TOUCH_PATH"
say_ok
exit 0
