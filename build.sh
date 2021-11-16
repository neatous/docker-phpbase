#!/bin/bash

set -e

REPOSITORY="neatous/phpbase"

docker build --no-cache . --tag=${REPOSITORY}:7.4
docker push ${REPOSITORY}:7.4
docker tag ${REPOSITORY}:7.4 ${REPOSITORY}:latest
docker push ${REPOSITORY}:latest
