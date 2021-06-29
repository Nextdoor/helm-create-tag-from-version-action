#!/bin/bash

# Exit on any failure.
set -eu

# Figure out our source branch or tag...
SOURCE_NAME=${GITHUB_REF#refs/*/}

if [[ "${GITHUB_REF}" == "refs/pull"* ]]; then
  echo "Cannot execute merge from a pull request. Exiting."
  exit 0
fi

_merge_to_dest_branch() {
  # https://github.com/actions/checkout/issues/164#issuecomment-592281100
  sudo chmod -R ugo+rwX .

  git checkout ${INPUT_RELEASE_BRANCH}

  git log ${INPUT_RELEASE_BRANCH}..${SOURCE_NAME}
  git merge \
    --message "[${INPUT_COMMIT_USER_NAME}] Merge from ${SOURCE_NAME}" \
    --commit \
    --stat \
    --no-ff \
    "${SOURCE_NAME}"
}

# Be really loud and verbose if we're running in VERBOSE mode
if [ "${INPUT_VERBOSE}" == "true" ]; then
  set -x
  echo "Environment:"
  env
  echo "Arguments: $@"
fi

_merge_to_dest_branch
