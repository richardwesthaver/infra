# nushell/env.nu

$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

$env.ESHELL = '/bin/bash'
$env.ORGANIZATION = 'The Compiler Company'
$env.EDITOR = "emacsclient -c -a=''"
$env.LISP = "sbcl"
$env.ALTERNATE_EDITOR = ''
