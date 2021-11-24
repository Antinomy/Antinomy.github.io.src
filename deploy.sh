#!/usr/bin/env bash

hexo clean
hexo generate --deploy

./autoGit.sh