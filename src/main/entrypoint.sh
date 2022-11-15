#!/bin/bash
# @file entrypoint.sh
# @brief Entrypoint for Github Action.
#
# @description Entrypoint for Github Action. This script updates the version in a projects antora.yml and sets either `main` or `<branchname>` depending on the current branch.
#
# IMPORTANT: Do not run this script directly. This script is intended to run as part of a Github Actions job.
#
# === Script Arguments
#
# . *$1* (string) git_ref: current branch / tag (mandatory)
# . *$2* (string) file: path to antora.yml (default = ``docs/antora.yml``) (optional)


ANTORA_YML="$2"
BRANCH="$1"


# @description Adjust version from 'main' to '<branchname>' or to '<version>' for release branches (if not already correct).
function mainToBranchname() {
    old="refs/heads/"
    BRANCH="${BRANCH//$old/}"

    # antora does not allow slashes in versions
    old="/"
    new="__"
    BRANCH="${BRANCH/$old/$new}"

    # remove the prefix for release branches
    old="release__"
    BRANCH="${BRANCH/$old/}"

    oldPattern='version: '
    new="version: $BRANCH"
    sed -i "/$oldPattern/s/.*/$new/" "$ANTORA_YML"
}


# @description Adjust version from '<branchname>' to 'main' if not already correct ... run on main branch.
function branchnameToMain() {
    oldPattern='version: '
    new='version: main'
    sed -i "/$oldPattern/s/.*/$new/" "$ANTORA_YML"
}


echo "Update version in $ANTORA_YML"
echo "Current ref = $BRANCH"
case "$BRANCH" in 
  *"refs/heads/feat/"* ) mainToBranchname ;;
  *"refs/heads/release/"* ) mainToBranchname ;;
  *"refs/heads/main"* ) branchnameToMain ;;
esac

cat "$ANTORA_YML"
