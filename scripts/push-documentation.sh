#!/bin/bash

github_user=$1
github_password=$2

cd Documentation

cd build
rm -rf gh-pages
git clone -b gh-pages https://"$github_user":"$github_password"@github.com/gini/gini-sdk-ios.git gh-pages

rm -rf gh-pages/*
mkdir gh-pages/docs
cp -a html/. gh-pages/docs/

mkdir gh-pages/api
cp -a ../Api/. gh-pages/api/

cd gh-pages
touch .nojekyll

git config user.name "Geonosis CI"
git config user.email "hello@gini.net" # Use Schorschis Account
git add -u
git add .
git diff --quiet --exit-code --cached || git commit -a -m 'Deploy Gini SDK iOS documentation to Github Pages'
git push
