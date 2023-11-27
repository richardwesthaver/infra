#!/usr/bin/bash
# scripts/git-vendor-pull.sh git.savannah.gnu.org/git emacs master
DOMAIN="${1}"
REMOTE="https://$DOMAIN/${2}"
REPO="ssh://git@vc.compiler.company/packy/shed/vendor/${2}"
BRANCH="${3:-master}"
OUT="${4:-build/${2}}"
git clone $REPO $OUT
pushd $OUT
git pull $REMOTE $BRANCH
git push $REPO
popd
