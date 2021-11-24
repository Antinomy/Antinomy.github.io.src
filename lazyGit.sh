#!/bin/sh

current_time=`date "+%Y%m%d%H%M%S"`

current_path=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

echo "Git working on path : $current_path"
echo "Git working on time : $current_time"

cd $current_path

git add -A

git commit -m "$current_time"

git push origin master