#!/usr/bin/env bash

set -e

if [[ "false" != "$TRAVIS_PULL_REQUEST" ]]; then
	echo "Not deploying pull requests."
	exit
fi

if [[ "master" != "$TRAVIS_BRANCH" ]]; then
	echo "Not on the 'master' branch."
	exit
fi

rm -rf .git
rm -r .gitignore

echo "bin
spec
node_modules
bower.json
package.json
gulpfile.coffee
gulpfile.js
.bowerrc
.travis.yml
src/*.coffee
src/*.scss
.gitignore
id_ecdsa.enc" > .gitignore

git init
git config user.name "kamataryo"
git config user.email "from_travis@example.com"
git remote add origin "git@github.com:${TRAVIS_REPO_SLUG}.git"
git add .
git commit -m "Deploy from travis[no ci]"
git push --force origin gh-pages
