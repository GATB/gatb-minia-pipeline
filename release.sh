#!/bin/bash

soft=gatb-pipeline

#make a version number
version="1.`git rev-list HEAD | wc -l`"
echo "version: $version"
mkdir $soft-$version

# create a changelog
git log --pretty=format:'%cd: %s' --date=short > CHANGELOG
echo "" >> CHANGELOG # it was missing a \n

# so, I did the following system:
# dependencies/ holds the release packages of kmergenie/minia
# this script will extract them to the correct dirs

# extract kmergenie release to kmergenie/
tar xf dependencies/kmergenie* -C $soft-$version/
mv $soft-$version/kmergenie*/ $soft-$version/kmergenie

# extract minia release to minia/
tar xf dependencies/minia* -C $soft-$version/
mv $soft-$version/minia*/ $soft-$version/minia

# package the rest
cp gatb README CHANGELOG Makefile $soft-$version/
mkdir -p $soft-$version/test/
cp -R test/small_test_reads.fa $soft-$version/test/
cp -R sspace $soft-$version/
cp -R tools $soft-$version/

tar -chzf $soft-$version.tar.gz $soft-$version/
#rm -Rf $soft-$version/

if [ "$1" == "--just-pack" ]
then
    exit 0
fi

# todo: upload that to gatb website
