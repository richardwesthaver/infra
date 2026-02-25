#!/usr/bin/env bash

# based on https://github.com/GrammaTech/sel/blob/master/tools/tree-sitter-install.sh
set -eux

declare -ar default_langs=(
  commonlisp bash c cpp css go html java javascript jsdoc json python regex rust
  typescript/tsx typescript/typescript yaml
) 
# see https://tree-sitter.github.io/tree-sitter/#parsers for a
# complete list of parsers available
TARGETDIR="${1:-.stash/src/tree-sitter-langs}"
PREFIX=$(realpath "${2:-${PREFIX:-/usr}}")
CC=${CC:-cc}
CXX=${CXX:-c++}
if [ $(uname) == "Darwin" ];then
   EXT=dylib;
else
   EXT=so
fi

declare -A repos
repos[commonlisp]=https://github.com/theHamsta/tree-sitter-commonlisp.git
repos[yaml]=https://github.com/ikatyang/tree-sitter-yaml.git
repos[cpp]=https://github.com/ruricolist/tree-sitter-cpp.git

declare -a langs
if [ -z "${3:-}" ]; then
  langs=(${default_langs[@]})
else
  langs=($@)
fi

mkdir -pv $TARGETDIR
cd $TARGETDIR
for lang in "${langs[@]}";do
  [ -d "tree-sitter-${lang%/*}" ] || git clone ${repos[$lang]:-https://github.com/tree-sitter/tree-sitter-${lang%/*}};
  # subshell
  (
    cd "tree-sitter-${lang}/src";
    if test -f "scanner.cc"; then
      ${CXX} -I. -fPIC scanner.cc -c -lstdc++;
      ${CC} -I. -std=c99 -fPIC parser.c -c;
      ${CXX} -shared scanner.o parser.o -o ${PREFIX}/lib/libtree-sitter-"${lang//\//-}.${EXT}";
    elif test -f "scanner.c"; then
      ${CC} -I. -std=c99 -fPIC scanner.c -c;
      ${CC} -I. -std=c99 -fPIC parser.c -c;
      ${CC} -shared scanner.o parser.o -o ${PREFIX}/lib/libtree-sitter-"${lang//\//-}.${EXT}";
    else
      ${CC} -I. -std=c99 -fPIC parser.c -c;
      ${CC} -shared parser.o -o ${PREFIX}/lib/libtree-sitter-"${lang//\//-}.${EXT}";
    fi;
    mkdir -p "${PREFIX}/share/tree-sitter/${lang}/";
    cp grammar.json node-types.json "${PREFIX}/share/tree-sitter/${lang}";
  )
done
