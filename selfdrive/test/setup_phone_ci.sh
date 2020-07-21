#!/usr/bin/bash set -e

SOURCE_DIR="/data/openpilot_source/"
#TEST_DIR="/data/openpilot/"

if [ ! -z "$GIT_COMMIT" ]; then
  echo "GIT_COMMIT must be set"
  exit 1
fi

# clear scons cache dirs that haven't been written to in one day
cd /tmp && find -name 'scons_cache_*' -type d -maxdepth 1 -mtime 1 -exec rm -rf '{}' \;

# set up environment
cd $SOURCE_DIR
git reset --hard
git fetch origin
find . -maxdepth 1 -not -path './.git' -not -name '.' -not -name '..' -exec rm -rf '{}' \;
git reset --hard $GIT_COMMIT
git checkout $GIT_COMMIT
git clean -xdf
git submodule update --init
git submodule foreach --recursive git reset --hard
git submodule foreach --recursive git clean -xdf
echo "git took $SECONDS seconds"

rsync -a --delete $SOURCE_DIR $TEST_DIR
#cd $TEST_DIR

echo "$TEST_DIR synced with $GIT_COMMIT, took $SECONDS seconds"