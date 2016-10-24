#!/bin/bash
#set -x

DOCKER_NAME=iwfwebsolutions
BUILD_NAME=phpfpm

REVISIONCOUNT=$(git log --oneline | wc -l | tr -d ' ')
#PROJECTVERSION=$(git describe --tags --long)
PROJECTVERSION=$(git describe --abbrev=0 --tags --exact-match)
CLEANVERSION=${PROJECTVERSION%%-*}
#echo "Full build: $projectversion-$revisioncount"
GIT_BRANCH=$(git name-rev --name-only HEAD | sed "s/~.*//")
GIT_COMMIT=$(git rev-parse HEAD)
GIT_COMMIT_SHORT=$(echo $GIT_COMMIT | head -c 8)
GIT_DIRTY='false'
BUILD_CREATOR=$(git config user.email)

if [ ! -z $PROJECTVERSION ]; then
  BUILD_NUMBER=$PROJECTVERSION
  # As we build for 5.6 base, we set it explicitly
  DOCKER_LATEST_TAG=5.6-latest
else
  BUILD_NUMBER=${GIT_BRANCH}-$GIT_COMMIT_SHORT
  DOCKER_LATEST_TAG=${GIT_BRANCH}-latest
fi

# Whether the repo has uncommitted changes
if [[ $(git status -s) ]]; then
    GIT_DIRTY='true'
fi

echo "===> Building docker image '$BUILD_NAME' with build '$BUILD_NUMBER' ..."

# Add "-q" for silence...
docker build \
  --no-cache \
  -f ./docker/build/Dockerfile \
  -t $DOCKER_NAME/$BUILD_NAME:$DOCKER_LATEST_TAG \
  -t $DOCKER_NAME/$BUILD_NAME:$BUILD_NUMBER \
  --build-arg GIT_BRANCH="$GIT_BRANCH" \
  --build-arg GIT_COMMIT="$GIT_COMMIT" \
  --build-arg GIT_DIRTY="$GIT_DIRTY" \
  --build-arg BUILD_CREATOR="$BUILD_CREATOR" \
  --build-arg BUILD_NUMBER="$BUILD_NUMBER" \
  .

echo "Done"
echo "Push to docker registry using:"
echo "  docker push $DOCKER_NAME/$BUILD_NAME:$DOCKER_LATEST_TAG"
echo "  docker push $DOCKER_NAME/$BUILD_NAME:$BUILD_NUMBER"
