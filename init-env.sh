#!/bin/bash

echo "check and config env"
if [ -n  $(node -v) ];then
    echo "node is installed, version is:" $(node -v)
else
    echo "node is not installed"
fi

if [ -n  $(npm -v) ];then
    echo "npm is installed, version is:" $(npm -v)
    npm config set registry=https://registry.npm.taobao.org/
else
    echo "npm is not installed"
fi

echo "start recover env for nutao hexo blog"
npm install -g hexo-cli
npm install
npm install hexo-deployer-git --save

# download theme
git submodule init && git submodule update --remote

# configuratin
cp ./themes/_config.yml themes/next/_config.yml

echo "try hexo --version to check env"
