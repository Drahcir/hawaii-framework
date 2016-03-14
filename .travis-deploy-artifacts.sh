#!/bin/bash

set -e
set +x

# Do not deploy archives when building pull request
if [ "$TRAVIS_BRANCH" != "master" ] || [ "$TRAVIS_PULL_REQUEST" == "true" ]; then
  exit 0
fi

# Deploy jar artifacts to Sonatype OSSRH

./gradlew uploadArchives

# Deploy api and reference documentation to gh-pages

HAWAII_FRAMEWORK_VERSION=`cat gradle.properties | grep "version" | cut -d'=' -f2`
GH_PAGES_DIR=.gh-pages
GH_REF=github.com/hawaiifw/hawaii-framework

rm -rf $GH_PAGES_DIR
git clone --quiet --branch=gh-pages https://${GH_TOKEN}@${GH_REF} $GH_PAGES_DIR > /dev/null 2>&1

rm -rf $GH_PAGES_DIR/docs/$HAWAII_FRAMEWORK_VERSION
mkdir -p $GH_PAGES_DIR/docs/$HAWAII_FRAMEWORK_VERSION
unzip -o build/distributions/hawaii-framework-${HAWAII_FRAMEWORK_VERSION}-docs.zip -d $GH_PAGES_DIR/docs/$HAWAII_FRAMEWORK_VERSION

git -C $GH_PAGES_DIR config user.email "travis@travis-ci.org"
git -C $GH_PAGES_DIR config user.name "Travis"
git -C $GH_PAGES_DIR add --all
git -C $GH_PAGES_DIR commit --allow-empty -m "Travis build $TRAVIS_BUILD_NUMBER pushed docs to gh-pages"
git -C $GH_PAGES_DIR push origin gh-pages > /dev/null 2>&1

rm -rf $GH_PAGES_DIR
