### infra/makefile --- The Compiler Company Infrastructure
__ := $(.VARIABLES)
LINUX_VERSION:=$(shell uname -r | cut -d- -f1)
EMACS_VERSION:=main
ROCKSDB_VERSION:=main
SBCL_VERSION:=main
RUST_VERSION:=main
SRC:=comp
SHELL=/bin/sh
UNAME=$(shell uname)
CURL:=curl
CPU_COUNT:=$(shell getconf _NPROCESSORS_ONLN)
HG_COMMIT:=$(shell hg id -i)
VERSION:=
VARS:=$(foreach v,$(filter-out $(__) __,$(.VARIABLES)),"\n$(v) = $($(v))")

all:dist

clean:linux-clean dist-clean;

### Linux
LINUX_TARGET:=linux-$(LINUX_VERSION)
linux:$(LINUX_TARGET) linux-config;
	mv build/$< dist/$<
$(LINUX_TARGET):scripts/get-linux.sh;
	mkdir -pv build/$@
	gpg --export autosigner@ torvalds@ gregkh@ > build/$@/keyring.gpg
	$< $(LINUX_VERSION) build build/$@/keyring.gpg
	cd build && unxz $@.tar.xz && tar -xvf $@.tar $(LINUX_TARGET)
linux-config:$(LINUX_TARGET);
	cd build/$< && make mrproper -j && zcat /proc/config.gz > .config && make localmodconfig
linux-clean::;rm -rf build/$(LINUX_TARGET)*

### Emacs
EMACS_TARGET:=emacs-$(EMACS_VERSION)
emacs:scripts/get-emacs.sh;
	$< $(EMACS_VERSION)

### RocksDB
ROCKSDB_TARGET:=rocksdb-$(ROCKSDB_VERSION)
rocksdb:scripts/get-rocksdb.sh;
	$< $(ROCKSDB_VERSION)

### SBCL
SBCL_TARGET:=sbcl-$(SBCL_VERSION)
sbcl:scripts/get-sbcl.sh;
	$< $(SBCL_VERSION)

### Rust
RUST_TARGET:=rocksdb-$(ROCKSDB_VERSION)
rust:scripts/get-rust.sh
	$< $(RUST_VERSION)

### Code
code:scripts/get-code.sh
	$< $(SRC)

### Virt
pod:virt/build-pod.sh
	$<
archlinux:virt/build-archlinux-base.sh
	$<
fedora:virt/build-fedora-base.sh
	$<
box:virt/build-box-base.sh
	$<
bbdb:virt/build-bbdb-base.sh
	$<
heptapod:virt/build-heptapod.sh
	$<
heptapod-runner:virt/build-heptapod-runner.sh
	$<

### Web
compiler.company:;
the.compiler.company:;
vc.compiler.company:;
cdn.compiler.company:;
packy.compiler.company:;

### Dist
dist/code:scripts/bundle.sh
	$<

dist/style:style
	cp $< $@

dist:dist/code dist/style

dist-clean::;rm -rf dist/*
