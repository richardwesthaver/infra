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
B:=build
D:=dist
SRC:=code
HG_COMMIT:=$(shell hg id -i)
DESTINATION:=/mnt/y/data/packy
# requires emacs-build-minimal
# artifacts can deploy to dist/TARGET - need target triple first
# init:sbcl rust emacs rocksdb code
# dist/linux dist/rust dist/bundle
box:Containerfile.box;podman build -f $< -t localhost/infra/box
worker:Containerfile.worker;podman build -f $< -t localhost/infra/worker
operator:Containerfile.operator;podman build -f $< -t localhost/infra/operator
quick:code
all:dist/cdn dist/code dist/lisp dist/rust dist/sbcl dist/rocksdb dist/emacs
clean:;rm -rf $(B) $(D)
$(B):;mkdir -pv $@/src
$(D):;mkdir -pv $@/bin $@/lib $@/include $@/bundle $@/share
$(DESTINATION):$(D);cd $< && cp -rf ./* $@
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
EMACS_TARGET:=build/src/emacs
EMACS_DIST:=$(D)/src/emacs
$(EMACS_TARGET):scripts/get-emacs.sh $(B);
	$<
emacs:$(EMACS_TARGET)
emacs-build:scripts/build-emacs.sh $(EMACS_TARGET)
	cd $(EMACS_TARGET) && ./autogen.sh
	$<
emacs-build-mini:scripts/build-emacs-mini.sh emacs
	cd $(EMACS_TARGET) && ./autogen.sh
	$< $(EMACS_TARGET)
emacs-install:$(EMACS_TARGET);
	cd $< && make install

### RocksDB
ROCKSDB_TARGET:=build/src/rocksdb
$(ROCKSDB_TARGET):scripts/get-rocksdb.sh $(B)
	$<
rocksdb:$(ROCKSDB_TARGET)

rocksdb-build-shared:$(ROCKSDB_TARGET)
	cd $< && make shared_lib DISABLE_JEMALLOC=1

rocksdb-build-static:$(ROCKSDB_TARGET)
	cd $< && make static_lib DISABLE_JEMALLOC=1

rocksdb-install:$(ROCKSDB_TARGET)
	cd $< && make install

### Nushell
NUSHELL_TARGET:=build/src/nushell
$(NUSHELL_TARGET):scripts/get-nushell.sh;$<
nushell:$(NUSHELL_TARGET)
# build without clipboard to avoid errors at runtime in container env
nushell-build:$(NUSHELL_TARGET)
	cd $< && cargo build --workspace --release --no-default-features --features=default-no-clipboard,dataframe,extra --locked
nushell-install:$(NUSHELL_TARGET) nushell-build
	cd $< && ./scripts/install-all.sh
### SBCL
SBCL_TARGET:=build/src/sbcl
SBCL_VERSION:=2.4.2+
$(SBCL_TARGET):scripts/get-sbcl.sh $(B)
	$<
	cd $(SBCL_TARGET) && \
	echo '"$(SBCL_VERSION)"' > version.lisp-expr
sbcl:$(SBCL_TARGET)
#### --with-sb-fasteval --without-sb-eval < broken
sbcl-build:$(SBCL_TARGET)
	cd $< && \
	./make.sh \
	--without-gencgc \
	--with-mark-region-gc \
	--dynamic-space-size=8Gb \
	--fancy
sbcl-build-shared:$(SBCL_TARGET) sbcl-build
	cd $< && \
	./make-shared-library.sh \
sbcl-build-gencgc:$(SBCL_TARGET)
	cd $< && \
	./make.sh \
	--dynamic-space-size=8Gb \
	--fancy
sbcl-docs:sbcl-build;## REQUIRES TEXLIVE
	cd $(SBCL_TARGET)/doc/manual && make
sbcl-install:sbcl-build;cd $(SBCL_TARGET) && INSTALL_ROOT=/usr/local sh install.sh
clean-sbcl:$(SBCL_TARGET);cd $(SBCL_TARGET) && ./clean.sh

build/quicklisp.lisp:$(B);cd $< && curl -O https://beta.quicklisp.org/quicklisp.lisp
quicklisp-install:scripts/quicklisp-install.sh build/quicklisp.lisp;$<
STUMPWM_TARGET:=build/src/stumpwm

$(STUMPWM_TARGET):scripts/get-stumpwm.sh $(B);$<
stumpwm:$(STUMPWM_TARGET);
stumpwm-build:stumpwm;
	cd $(STUMPWM_TARGET) && ./autogen.sh && ./configure && make
stumpwm-install:stumpwm-build;
	cd $(STUMPWM_TARGET) && make install
### Rust
RUST_TARGET:=build/src/rust
$(RUST_TARGET):scripts/get-rust.sh $(B);$<
rust:$(RUST_TARGET)
rust-install-x:rust;
	cargo install --path $(RUST_TARGET)/src/tools/x
rust-build:rust rust-install-x;
	cd $(RUST_TARGET) && x build library
rust-doc:rust rust-install-x;
	cd $(RUST_TARGET) && x doc
rust-build-full:rust-build;
	cd $(RUST_TARGET) && x build --stage 2 compiler/rustc
rust-install:rust-build;
	cd $(RUST_TARGET) && x install
rustup-install:;curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
cargo-tools-install:scripts/install-cargo-tools.sh
	$<
### Tree-sitter
TREE_SITTER_TARGET:=build/src/tree-sitter
$(TREE_SITTER_TARGET):scripts/get-tree-sitter.sh
	$<
tree-sitter:$(TREE_SITTER_TARGET)
tree-sitter-build:$(TREE_SITTER_TARGET)
tree-sitter-install:$(TREE_SITTER_TARGET) tree-sitter-build

### Tree-sitter Langs
TREE_SITTER_LANGS_TARGET:=build/src/tree-sitter-langs
tree-sitter-langs-install:scripts/tree-sitter-install-langs.sh
	$<
### Code
CODE_TARGET:=build/src/$(SRC)
$(CODE_TARGET):scripts/get-code.sh $(B)
	$< $(SRC)
code:$(CODE_TARGET)
clean-code::;rm -rf $(CODE_TARGET)

### Dist
dist/bundle:scripts/bundle-code.sh $(CODE_TARGET)
	mkdir -pv $@
	$<

dist/cdn:cdn $(D)
	mkdir -pv $@
	cp -r $</* $@

dist/sbcl:$(D);
	scripts/dist-sbcl-binary.sh $(SBCL_TARGET) $(D)
	cd $(SBCL_TARGET) && sh ./clean.sh
	scripts/dist-sbcl-source.sh $(SBCL_TARGET) $(D)

dist/linux:linux $(D);

dist/rocksdb:$(D) rocksdb;
	cd build/src && \
	tar -I 'zstd' -cf ../../$</rocksdb-binary.tar.zst rocksdb/include/* rocksdb/librocksdb.*

CORE_SRC?=/usr/local/src/core

dist/rust:rust-build $(D);
	cd $(RUST_TARGET) && x dist
dist/rust/bin:scripts/cargo-install.sh
	mkdir -pv $@
	$< "$(CORE_SRC)/rust/app/cli/alik" dist/rust
	$< "$(CORE_SRC)/rust/app/cli/krypt" dist/rust
	$< "$(CORE_SRC)/rust/app/cli/tz" dist/rust
	$< "$(CORE_SRC)/rust/app/cli/cc-install" dist/rust
	$< "$(CORE_SRC)/rust/app/cli/mailman" dist/rust

dist/emacs:emacs-build $(D);
	cd $(EMACS_TARGET) && ./make-dist --no-info --no-changelog && \
	mv emacs-*.*.* emacs && \
	tar -I 'zstd' -cf ../../../dist/emacs-binary.tar.zst emacs

dist/emacs-mini:emacs-build-mini $(D);
	cd $(EMACS_TARGET) && ./make-dist --no-info --no-changelog && \
	mv emacs-*.*.* emacs && \
	tar -I 'zstd' -cf ../../../dist/emacs-mini-binary.tar.zst emacs

dist/nushell:$(D) nushell-build
	cd $(NUSHELL_TARGET)/target/release/ && \
	tar -I 'zstd' -cf ../../../../../$</nushell.tar.zst \
	nu nu_plugin_custom_values nu_plugin_formats nu_plugin_gstat \
	nu_plugin_inc nu_plugin_query

dist/tree-sitter:scripts/tree-sitter-install-langs.sh $(D)
	PREFIX=$(D) $<

# requires quicklisp loaded in .skelrc
dist/lisp/fasl:scripts/sbcl-save-core.sh
	mkdir -pv $@
	$< "$@/std.core"
	$< "$@/prelude.core" "(mapc #'ql:quickload \
	(list :nlp :rdb :organ :packy :skel :obj :net :parse :pod :dat :log :packy :rt :syn :xdb :doc :vc))"

dist/lisp/bin:scripts/sbcl-make-bin.sh
	mkdir -pv $@
	$< bin/skel
	mv $(CORE_SRC)/lisp/app/bin/skel $@
	rm -f $(CORE_SRC)/lisp/app/bin/skel.fasl
	$< bin/organ
	cp $(CORE_SRC)/lisp/app/bin/organ $@
	rm -f $(CORE_SRC)/lisp/app/bin/organ.fasl
	$< bin/homer
	cp $(CORE_SRC)/lisp/app/bin/homer $@
	rm -f $(CORE_SRC)/lisp/app/bin/homer.fasl
	$< bin/packy
	cp $(CORE_SRC)/lisp/app/bin/packy $@
	rm -f $(CORE_SRC)/lisp/app/bin/packy.fasl
	$< bin/rdb
	cp $(CORE_SRC)/lisp/app/bin/rdb $@
	rm -f $(CORE_SRC)/lisp/app/bin/rdb.fasl

dist/lisp:dist/lisp/fasl dist/lisp/bin

core-lisp-install:dist/lisp
	install -m 755 $</bin/* /usr/local/bin/
	install -m 755 $</fasl/* /usr/local/lib/sbcl/

core-rust-install:dist/rust/bin
	install -m 755 $</* /usr/local/bin/

core-install:core-lisp-install core-rust-install

dist/core:dist/rust/bin dist/lisp
	mkdir -pv $@
	cp -rf dist/lisp/fasl dist/lisp/bin $@
	cp -rf $< $@
	cd dist && tar -I 'zstd' -cf core.tar.zst core
dist/code:code
	mkdir -pv $@
	cp -r $(CODE_TARGET)/{org,core,infra,demo} $@
clean-dist:;rm -rf $(D)
clean-build:;rm -rf $(B)
