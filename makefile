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

all:linux emacs rocksdb sbcl rust code virt dist;

clean:linux-clean code-clean dist-clean;

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
	cd build/$< && make mrproper -j && zcat /proc/config.gz > .config && yes N | make localmodconfig
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
RUST_TARGET:=rust-$(RUST_VERSION)
rust:scripts/get-rust.sh
	$< $(RUST_VERSION)
rust-install-x:rust;
	cargo install --path build/$(RUST_TARGET)/src/tools/x
rust-build:rust rust-install-x;
	cd build/$(RUST_TARGET) && x build library
rust-doc:rust rust-install-x;
	cd build/$(RUST_TARGET) && x doc
rust-build-full:rust-build;
	cd build/$(RUST_TARGET) && x build --stage 2 compiler/rustc
rust-install:rust-build;
	cd build/$(RUST_TARGET) && x install
rust-dist:rust-build;
	cd build/$(RUST_TARGET) && x dist
### Code
code:scripts/get-code.sh
	$< $(SRC)

code-clean::;rm -rf build/$(SRC)*

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

vc:heptapod heptapod-runner

virt:pod box bbdb vc
### Web

### Dist
dist/code:scripts/bundle.sh
	$<

dist/cdn:cdn
	cp -r $^ $@

dist/sbcl:sbcl;

dist/linux:linux;

dist/rocksdb:rocksdb;

dist/emacs:emacs;

dist:dist/code dist/cdn dist/sbcl dist/linux dist/rocksdb

dist-clean::;rm -rf dist/*
