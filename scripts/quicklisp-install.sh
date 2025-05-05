#!/bin/bash
set -xe
if [ -z "$HOME" ]; then  HOME="/root"
fi
QUICKLISP_HOME="${1:$HOME/.stash/quicklisp/}"
if [ -z "$QUICKLISP_DIST_VERSION" ] || [ "$QUICKLISP_DIST_VERSION" = "latest" ]; then
    QUICKLISP_DIST_VERSION=nil
else
    QUICKLISP_DIST_VERSION="\"quicklisp/$QUICKLISP_DIST_VERSION\""
fi

if [ -z "$QUICKLISP_CLIENT_VERSION" ] || [ "$QUICKLISP_CLIENT_VERSION" = "latest" ]; then
    QUICKLISP_CLIENT_VERSION=nil
else
    QUICKLISP_CLIENT_VERSION="\"$QUICKLISP_CLIENT_VERSION\""
fi
$LISP --non-interactive \
     --load .stash/quicklisp.lisp \
     --eval "(quicklisp-quickstart:install :path \"$QUICKLISP_HOME\" :dist-version $QUICKLISP_DIST_VERSION :client-version $QUICKLISP_CLIENT_VERSION)" \
     --eval "(ql-dist:install-dist \"http://dist.ultralisp.org/\" :prompt nil)"
