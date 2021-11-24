#!/bin/sh

current_path=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

cd $current_path

# git show --stat | tail -1 | awk '{print $1}'

git status -s | wc -l