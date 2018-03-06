#! /data/data/com.termux/files/usr/bin/bash

ROOT_PATH=""

while getopts r: option
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

cd "$ROOT_PATH"
if [ "$?" -gt 0 ]; then
    "$SHELL" say_error "Cannot cd to '$ROOT_PATH'"
    exit 1
fi

git diff --exit-code >/dev/null 2>&1
if [ "$?" -gt 0 ]; then
    git commit -a -m 'phone updates'
    if [ "$?" -gt 0 ]; then
        "$SHELL" say_error "Cannot commit"
        exit 1
    fi
fi
    
git pull
if [ "$?" -gt 0 ]; then
    "$SHELL" say_error "Cannot pull"
    exit 1
fi

git push
if [ "$?" -gt 0 ]; then
    "$SHELL" say_error "Cannot push"
    exit 1
fi

"$SHELL" say_ok
exit 0
