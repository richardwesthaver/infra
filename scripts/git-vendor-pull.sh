#!/usr/bin/env bash
# pull a vendored dependency and push to upstream vc

# scripts/git-vendor-pull.sh git.savannah.gnu.org/git emacs master
NAME="${1}"
DOMAIN="${2}"
REMOTE="https://$DOMAIN/$NAME"
BRANCH="${2:-master}"
REPO="ssh://git@vc.compiler.company/packy/shed/vendor/${1}"
OUT="${3:-build/src/${1}}"
mkdir -pv build/src
git clone $REPO $OUT
pushd $OUT
git pull $REMOTE $BRANCH
git push $REPO
popd
