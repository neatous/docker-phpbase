#!/bin/bash

set -e

GIT_BRANCH=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [ "${GIT_BRANCH}" = "master" ]
then
  TAG="latest"
else
  TAG=${GIT_BRANCH}
fi

REPOSITORY="neatous/phpbase"
#TAG="latest"

docker build --no-cache . --tag=${REPOSITORY}:${TAG}
docker push ${REPOSITORY}:${TAG}
