### common.mk --- common infra rules

### Code:
__ := $(.VARIABLES)
COMMON_MK=$(lastword $(MAKEFILE_LIST))
INFRA_DIR=$(realpath $(dir $(COMMON_MK)))
INFRA_LISP_FILES=$(shell find $(INFRA_DIR) -type f \( -name '*.asd' -o -name '*.lisp' \) )
INFRA_BUILD_DIR=$(INFRA_DIR)/build
INFRA_DIST_DIR=$(INFRA_DIR)/dist
INFRA_SCRIPT_DIR=$(INFRA_DIR)/scripts
LINUX_VERSION:=$(shell uname -r | cut -d- -f1)
SHELL=/bin/sh
UNAME=$(shell uname)
CURL:=curl
CPU_COUNT:=$(shell getconf _NPROCESSORS_ONLN)
HG_COMMIT:=$(shell hg id -i)
VERSION:=
VARS:=$(foreach v,$(filter-out $(__) __,$(.VARIABLES)),"\n$(v) = $($(v))")
