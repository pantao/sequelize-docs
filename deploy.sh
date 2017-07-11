#!/bin/bash

USER=root
HOST=10.10.2.164
ROOT_DIR=/opt/etd_apps/codex.etongdai.org/public

group=`git remote -v | awk -F"@" '{print $2}' | awk -F"/" '{print $2}' | uniq`
artifact=`git remote -v | awk -F"@" '{print $2}' | awk -F"/" '{print $3}' | awk -F"." '{print $1}' | uniq`
project=${group}/${artifact}
echo $project

des_dir=$ROOT_DIR/$project
build_dir=./_book

## build book
gitbook build . ${build_dir}

## deploy
ssh -o StrictHostKeyChecking=no ${USER}@${HOST} "mkdir -p ${des_dir} && rm -fr ${des_dir}/*"
scp -o StrictHostKeyChecking=no -r ${build_dir}/* ${USER}@${HOST}:${des_dir}

## Links
echo Read this book at: http://codex.etongdai.org/${group}/${artifact}