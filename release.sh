#!/bin/bash

soft=gatb-pipeline

#make a version number
version="1.`git rev-list HEAD | wc -l`"
echo "version: $version"

rm -Rf $soft-$version/
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
rm -Rf $soft-$version/

if [ "$1" == "--just-pack" ]
then
    exit 0
fi

# uploading to gatb website

#ripped from Delivery.cmake, I know, sorry for duplicating code; this needs to
# be converted to cmake someday

CPACK_DATE=$(date +"%m-%d-%Y")
CPACK_SYSTEM_NAME=Linux
CPACK_SYSTEM_NAME_SRC=all

CMAKE_PROJECT_NAME="gatb-pipeline"
PROJECT_NAME="gatb-pipeline"
CPACK_PACKAGE_NAME="gatb-pipeline"
CPACK_VERSIONS_FILENAME="versions.txt"

CPACK_PACKAGE_VERSION=$version
CPACK_USER_NAME=chikhi
CPACK_SERVER_ADDRESS="${CPACK_USER_NAME}@scm.gforge.inria.fr"
CPACK_SERVER_DIR="/home/groups/${PROJECT_NAME}/htdocs/versions/"
CPACK_SERVER_VERSIONS="${CPACK_SERVER_DIR}/${CPACK_VERSIONS_FILENAME}"
CPACK_SERVER_DIR_BIN="${CPACK_SERVER_DIR}/bin/"
CPACK_SERVER_DIR_SRC="${CPACK_SERVER_DIR}/src/"

CPACK_URI_BIN="$soft-$version.tar.gz"
CPACK_URI_SRC="$soft-$version.tar.gz"

# We define the location where the bin and src targets have to be uploaded
CPACK_UPLOAD_URI_BIN="${CPACK_SERVER_ADDRESS}:${CPACK_SERVER_DIR_BIN}"
CPACK_UPLOAD_URI_SRC="${CPACK_SERVER_ADDRESS}:${CPACK_SERVER_DIR_SRC}"
CPACK_UPLOAD_VERSIONS="${CPACK_SERVER_ADDRESS}:${CPACK_SERVER_VERSIONS}"

# We set the text holding all the information about the delivery.
CPACK_INFO_BIN="${CMAKE_PROJECT_NAME} bin ${PROJECT_NAME} ${CPACK_PACKAGE_VERSION} ${CPACK_DATE} ${CPACK_SYSTEM_NAME} ${CPACK_USER_NAME} ${CPACK_URI_BIN}"
CPACK_INFO_SRC="${CMAKE_PROJECT_NAME} src ${PROJECT_NAME} ${CPACK_PACKAGE_VERSION} ${CPACK_DATE} ${CPACK_SYSTEM_NAME_SRC} ${CPACK_USER_NAME} ${CPACK_URI_SRC}"

# We get the versions.txt file from the server
echo "calling delivery.sh"
dependencies/delivery.sh "BIN_OTHER" ${PROJECT_NAME} ${CPACK_PACKAGE_VERSION} ${CPACK_UPLOAD_VERSIONS} ${CPACK_VERSIONS_FILENAME}  "${CPACK_INFO_BIN}"  ${CPACK_URI_BIN}   ${CPACK_UPLOAD_URI_BIN}
dependencies/delivery.sh "SRC_OTHER" ${PROJECT_NAME} ${CPACK_PACKAGE_VERSION} ${CPACK_UPLOAD_VERSIONS} ${CPACK_VERSIONS_FILENAME}  "${CPACK_INFO_SRC}"  ${CPACK_URI_SRC}   ${CPACK_UPLOAD_URI_SRC}

# some cleanup
rm -f versions.txt
mv  $soft-$version.tar.gz  archive/
