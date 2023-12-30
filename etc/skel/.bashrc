# ~/.bashrc --- interactive Bash session config

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias ec='emacsclient -c'
alias et='emacsclient -t'

PS1="\u [\!]:\t:\w\n  >> \[\e[0m\]"

export LANG=en_US.UTF-8

export LISP='sbcl'
export lr='rlwrap sbcl' # lisp repl
export ESHELL='/usr/bin/bash'
export ORGANIZATION='The Compiler Company'
export LANG=en_US.UTF-8
export ALTERNATE_EDITOR=''
export EDITOR='emacsclient -t'
export VISUAL='emacsclient -c'
