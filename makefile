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
worker:sbcl-install quicklisp-install
# artifacts can deploy to dist/TARGET - need target triple first
# init:sbcl rust emacs rocksdb code
# dist/linux dist/rust dist/bundle
quick:code
operator:core-lisp-install emacs-build-mini emacs-install
all:dist/cdn dist/code dist/lisp dist/rust dist/sbcl dist/rocksdb dist/emacs
clean:;rm -rf $(B) $(D)
$(B):;mkdir -pv $@/src
$(D):;mkdir -pv $@/bin $@/lib $@/include $@/bundle $@/share
$(DESTINATION):$(D);cd $< && cp -rf ./* $@
deploy:$(DESTINATION)
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

### ECL
ECL_TARGET:=build/src/ecl
$(ECL_TARGET):scripts/get-ecl.sh
	$<
	cd $@ && ./configure --prefix=/usr/local && \
	make
ecl:$(ECL_TARGET)
/usr/local/bin/ecl:$(ECL_TARGET)
	cd $< && make install 

# TODO: separate params
#	--without-gencgc \
#	--with-mark-region-gc \
### SBCL
SBCL_TARGET:=build/src/sbcl
$(SBCL_TARGET):scripts/get-sbcl.sh $(B)
	$<
	cd $(SBCL_TARGET) && \
	echo '"2.4.1+main"' > version.lisp-expr
sbcl:$(SBCL_TARGET)
sbcl-build:$(SBCL_TARGET)
	cd $< && \
	./make.sh \
	--without-gencgc \
	--with-mark-region-gc \
	--with-core-compression \
	--dynamic-space-size=4Gb \
	--fancy
sbcl-docs:sbcl-build;## REQUIRES TEXLIVE
	cd $(SBCL_TARGET)/doc/manual && make
sbcl-install:sbcl-build;cd $(SBCL_TARGET) && INSTALL_ROOT=/usr/local sh install.sh
clean-sbcl:$(SBCL_TARGET);cd $(SBCL_TARGET) && ./clean.sh

build/quicklisp.lisp:$(B);cd $< && curl -O https://beta.quicklisp.org/quicklisp.lisp
quicklisp-install:scripts/quicklisp-install.sh build/quicklisp.lisp;$<

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
cargo-tools-install:scripts/install-cargo-tools.sh
	$<
### Tree-sitter Langs
TS_LANGS_TARGET:=build/src/ts-langs
ts-langs-install:scripts/ts-install-langs.sh
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

dist/sbcl:sbcl-build $(D);
	scripts/dist-sbcl-binary.sh $(SBCL_TARGET) $(D)
	cd $(SBCL_TARGET) && ./distclean.sh
	scripts/dist-sbcl-source.sh $(SBCL_TARGET) $(D)

dist/linux:linux $(D);

dist/rocksdb:$(D) rocksdb;
	tar -I 'zstd' -cf $</rocksdb-binary.tar.zst $(ROCKSDB_TARGET)/include/* $(ROCKSDB_TARGET)/librocksdb.*

dist/rust:rust-build $(D);
	cd $(RUST_TARGET) && x dist
dist/rust/bin:scripts/cargo-install.sh code
	mkdir -pv $@
	$< "$(CODE_TARGET)/core/rust/app/cli/alik" "dist/rust"
	$< "$(CODE_TARGET)/core/rust/app/cli/krypt" "dist/rust"
	$< "$(CODE_TARGET)/core/rust/app/cli/tz" "dist/rust"
	$< "$(CODE_TARGET)/core/rust/app/cli/cc-init" "dist/rust"
	$< "$(CODE_TARGET)/core/rust/app/cli/mailman" "dist/rust"

dist/emacs:emacs-build $(D);

dist/ts:scripts/ts-install-langs.sh $(D)
	PREFIX=$(D) $<
# requires quicklisp loaded in .skelrc
dist/lisp/fasl:scripts/sbcl-save-core.sh quicklisp-install
	mkdir -pv $@
	$< "$@/std.core"
	$< "$@/prelude.core" "(mapc #'ql:quickload \
	(list :nlp :rdb :organ :packy :skel :obj :net :parse :pod :dat :log :packy :rt :syn :xdb :doc :vc :rt))"

CORE_SRC=/usr/local/src/core
dist/lisp/bin:scripts/sbcl-make-bin.sh quicklisp-install
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

dist/code:code
	mkdir -pv $@
	cp -r $(CODE_TARGET)/{org,core,infra,demo} $@
clean-dist:;rm -rf $(D)
clean-build:;rm -rf $(B)
