### infra/makefile --- The Compiler Company Infrastructure

# this makefile is used to build all of our source code, package it,
# and ship it to various locations. It is for internal-use only.

# If possible, use the packy (packy.compiler.company) to find and
# download a prepared bundle that suits your project needs.

# You probably don't want to install all targets unless you have lots
# of time and a powerful machine, although it is possible. Instead,
# just run the targets for the components you are missing in your
# local environment (compatible compiler versions, shared libraries,
# etc)

VERSION="0.1.0"
LINUX_VERSION:=$(shell uname -r | cut -d- -f1)
EMACS_VERSION:=main
ROCKSDB_VERSION:=main
SBCL_VERSION:=main
RUST_VERSION:=main
B:=build
D:=dist
SRC:=comp
HG_COMMIT:=$(shell hg id -i)

init:sbcl rust emacs rocksdb code virt;
dist:dist/bundle dist/cdn dist/sbcl dist/rocksdb # dist/linux dist/rust
clean:;rm -rf $(B) $(D)
$(B):;mkdir -pv $@/src
$(D):;mkdir -pv $@
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
EMACS_DIST:=$(D)/src/emacs
$(EMACS_TARGET):scripts/get-emacs.sh $(B);
	$< $(EMACS_VERSION)
emacs:$(EMACS_TARGET)
emacs-build:emacs scripts/build-emacs.sh;
	cd $(EMACS_TARGET) && ./autogen.sh
	scripts/build-emacs.sh $(EMACS_VERSION) $(EMACS_TARGET)
emacs-install:emacs-build;
	cd $(EMACS_TARGET) && make install

### RocksDB
ROCKSDB_TARGET:=build/src/rocksdb-$(ROCKSDB_VERSION)
rocksdb:scripts/get-rocksdb.sh;
	$< $(ROCKSDB_VERSION)
	cd $(ROCKSDB_TARGET) && \
	make shared_lib DISABLE_JEMALLOC=1

### SBCL
SBCL_TARGET:=build/src/sbcl-$(SBCL_VERSION)

$(SBCL_TARGET):scripts/get-sbcl.sh $(B);
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
sbcl:$(SBCL_TARGET)
sbcl-install:sbcl;$(SBCL_TARGET)/install.sh
clean-sbcl:;rm -rf $(SBCL_TARGET)

### Rust
RUST_TARGET:=build/src/rust-$(RUST_VERSION)
rust:scripts/get-rust.sh $(B);
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

### Tree-sitter Langs
TS_LANGS_TARGET:=build/src/ts-langs
ts-langs:scripts/ts-install-langs.sh # this requires sudo for now

### Code
CODE_TARGET:=build/src/$(SRC)
code:scripts/get-code.sh $(B)
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
dist/bundle:scripts/bundle-dir.sh $(D)
	$<

dist/cdn:cdn $(D)
	mkdir -pv $@
	cp -r $^ $@

dist/sbcl:sbcl $(D);
	$(SBCL_TARGET)/install.sh --prefix=$(D)

dist/linux:linux $(D);

dist/rocksdb:rocksdb $(D);
	cd $(ROCKSDB_TARGET)
	cp -rf include/* $(D)
	cp -f librocksdb.so* $(D)/lib/

dist/rust:rust-build $(D);
	cd $(RUST_TARGET) && x dist

dist/emacs:emacs-build $(D);

clean-dist:;rm -rf $(D)
clean-build:;rm -rf $(B)

### Quickstart
quick:init code
