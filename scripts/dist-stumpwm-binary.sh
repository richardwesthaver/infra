#!/bin/sh
set -e
cd .stash/src
tar -I 'zstd' -cf stumpwm.tar.zst stumpwm/stumpwm stumpwm/stumpwm.info
mv stumpwm.tar.zst ../
