#!/bin/bash

counter=`./countGit.sh | sed s/[[:space:]]//g`

echo "changed files : $counter"

if  (($counter > 2))
then
    ./lazyGit.sh
fi