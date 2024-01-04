#!/bin/sh
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
# installs to /usr/local/share/lisp
sbcl --non-interactive \
     --load build/quicklisp.lisp \
     --eval "(quicklisp-quickstart:install :path \"/usr/local/share/quicklisp\" :dist-version $QUICKLISP_DIST_VERSION :client-version $QUICKLISP_CLIENT_VERSION)"
