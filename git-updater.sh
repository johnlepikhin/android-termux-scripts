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
    echo "-r expected"
    say_error
    exit 1
fi

if [ -z "$TOUCH_PATH" ]; then
    echo "-t expected"
    say_error
    exit 1
fi

. ~/.bashrc

find "$ROOT_PATH" -newer "$TOUCH_PATH" | egrep -q '.*'
NO_NEW_FILES="$?"

if [ "$NO_NEW_FILES" -eq 1 ] && [ "$FORCE" -eq 0 ]; then
    say_ok;
    exit 0;
fi

cd "$ROOT_PATH" || say_error || exit 1
git pull || say_error || exit 1
if [ "$PULL_ONLY" -eq 0 ]; then
    git add .
    git commit -a -m 'phone updates'
    git push || say_error || exit 1
fi
touch "$TOUCH_PATH"
say_ok
exit 0
