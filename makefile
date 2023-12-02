### infra/makefile --- The Compiler Company Infrastructure
__ := $(.VARIABLES)
LINUX_VERSION:=$(shell uname -r | cut -d- -f1)
EMACS_VERSION:=main
ROCKSDB_VERSION:=main
SBCL_VERSION:=main
RUST_VERSION:=main
B:=build
D:=$(realpath dist)
SRC:=comp
SHELL=/bin/sh
UNAME=$(shell uname)
CURL:=curl
CPU_COUNT:=$(shell getconf _NPROCESSORS_ONLN)
HG_COMMIT:=$(shell hg id -i)
VERSION:=

VARS:=$(foreach v,$(filter-out $(__) __,$(.VARIABLES)),"\n$(v) = $($(v))")

all:linux emacs rocksdb sbcl rust code virt dist;

clean:clean-linux clean-code clean-sbcl clean-dist;

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
clean-linux::;rm -rf build/$(LINUX_TARGET)

### Emacs
EMACS_TARGET:=build/src/emacs-$(EMACS_VERSION)
EMACS_DIST:=$(DIST)/src/emacs
emacs:scripts/get-emacs.sh;
	$< $(EMACS_VERSION)

emacs-build:emacs scripts/build-emacs.sh;
	cd $(EMACS_TARGET)
	./autogen.sh
	mkdir -pv $(EMACS_DIST)
	scripts/build-emacs.sh $(EMACS_VERSION) $(EMACS_TARGET) $(EMACS_DIST)

emacs-install:emacs-build;
	cd $(EMACS_DIST)
	make install

### RocksDB
ROCKSDB_TARGET:=build/src/rocksdb-$(ROCKSDB_VERSION)
rocksdb:scripts/get-rocksdb.sh;
	$< $(ROCKSDB_VERSION)
	cd $(ROCKSDB_TARGET) 
	make shared_lib DISABLE_JEMALLOC=1

### SBCL
SBCL_TARGET:=build/src/sbcl-$(SBCL_VERSION)
sbcl:scripts/get-sbcl.sh;
	$< $(SBCL_VERSION)
	cd $(SBCL_TARGET) && \
	echo '"2.3.12+main"' > version.lisp-expr && \
	sh make.sh \
	  --without-gencgc \
	  --with-mark-region-gc \
	  --with-core-compression \
	  --with-sb-xref-for-internals \
	  --dynamic-space-size=4Gb \
	  --fancy && \
	cd doc/manual && make
clean-sbcl:;rm -rf $(SBCL_TARGET)

### Rust
RUST_TARGET:=build/src/rust-$(RUST_VERSION)
rust:scripts/get-rust.sh
	$< $(RUST_VERSION)
rust-x:rust;
	cargo install --path $(RUST_TARGET)/src/tools/x
rust-build:rust rust-install-x;
	cd $(RUST_TARGET) && x build library
rust-doc:rust rust-install-x;
	cd $(RUST_TARGET) && x doc
rust-build-full:rust-build;
	cd $(RUST_TARGET) && x build --stage 2 compiler/rustc
rust-install:rust-build;
	cd $(RUST_TARGET) && x install

### Code
CODE_TARGET:=build/src/$(SRC)
code:scripts/get-code.sh
	$< $(SRC)

clean-code::;rm -rf $(CODE_TARGET)

### Virt
dev-pod:virt/build-pod.sh
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

vc-pod:heptapod heptapod-runner

virt:pod box bbdb vc

### Dist
dist/bundle:scripts/bundle-dir.sh
	$<

dist/cdn:cdn
	mkdir -pv $@
	cp -r $^ $@

dist/sbcl:sbcl;
	$(SBCL_TARGET)/install.sh --prefix=$(D)

dist/linux:linux;

dist/rocksdb:rocksdb;
	cd $(ROCKSDB_TARGET)
	cp -rf include/* $(D)
	cp -f librocksdb.so* $(D)/lib/

dist/rust:rust-build;
	cd $(RUST_TARGET) && x dist

dist/emacs:emacs;

dist:dist/bundle dist/cdn dist/sbcl dist/rocksdb # dist/linux dist/rust

clean-dist::;rm -rf dist/*

### Quickstart
quick:code
