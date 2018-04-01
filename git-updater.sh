#! /data/data/com.termux/files/usr/bin/bash

ROOT_PATH=""
PULL_ONLY=0
COMMENT="phone updates"

while getopts r:p:c: option
do
    case "${option}"
    in
        r) ROOT_PATH=${OPTARG};;
        p) PULL_ONLY=${OPTARG};;
        c) COMMENT=${OPTARG};;
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


if [ "$PULL_ONLY" -eq 0 ]; then
    git diff --exit-code >/dev/null 2>&1
    if [ "$?" -gt 0 ]; then
        git add -A
        git commit -a -m "$COMMENT"
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

"$SHELL" say_ok
exit 0
