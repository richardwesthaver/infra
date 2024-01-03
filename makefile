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
SRC:=comp
HG_COMMIT:=$(shell hg id -i)

# requires emacs-build-minimal
worker:rocksdb-install sbcl-install ts-langs-install quicklisp-install
# init:sbcl rust emacs rocksdb comp virt;
# dist/linux dist/rust dist/bundle
all:dist/cdn dist/comp dist/lisp dist/rust dist/sbcl dist/rocksdb dist/emacs
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
EMACS_TARGET:=build/src/emacs
EMACS_DIST:=$(D)/src/emacs
$(EMACS_TARGET):scripts/get-emacs.sh $(B);
	$<
emacs:$(EMACS_TARGET)
emacs-build:emacs scripts/build-emacs.sh;
	cd $(EMACS_TARGET) && ./autogen.sh
	scripts/build-emacs.sh $(EMACS_TARGET)
emacs-install:emacs-build;
	cd $(EMACS_TARGET) && make install

### RocksDB
ROCKSDB_TARGET:=build/src/rocksdb
$(ROCKSDB_TARGET):scripts/get-rocksdb.sh $(B)
	$<
	cd $(ROCKSDB_TARGET) && \
	make shared_lib DISABLE_JEMALLOC=1
rocksdb:$(ROCKSDB_TARGET)

rocksdb-install:$(ROCKSDB_TARGET)
	cp -rf $(ROCKSDB_TARGET)/include/* /usr/local/include/
	cp -f $(ROCKSDB_TARGET)/librocksdb.* /usr/local/lib/

# TODO: separate params
#	--without-gencgc \
#	--with-mark-region-gc \
### SBCL
SBCL_TARGET:=build/src/sbcl
$(SBCL_TARGET):scripts/get-sbcl.sh $(B);
	$<
	cd $(SBCL_TARGET) && \
	echo '"2.4.1+main"' > version.lisp-expr && \
	sh make.sh \
	--with-sb-xref-for-internals \
	--with-core-compression \
	--dynamic-space-size=8Gb \
	--fancy
sbcl:$(SBCL_TARGET)
sbcl-docs:sbcl;## REQUIRES TEXLIVE
	cd $(SBCL_TARGET)/doc/manual && make
sbcl-install:sbcl;cd $(SBCL_TARGET) && ./install.sh
clean-sbcl:$(SBCL_TARGET);cd $(SBCL_TARGET) && ./clean.sh
build/quicklisp.lisp:;curl -o build/quicklisp.lisp -O https://beta.quicklisp.org/quicklisp.lisp
quicklisp-install:build/quicklisp.lisp
	sbcl --script $< --eval '(quicklisp-quickstart:install)'
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

### Tree-sitter Langs
TS_LANGS_TARGET:=build/src/ts-langs
ts-langs-install:scripts/ts-install-langs.sh
	$<
### Comp
COMP_TARGET:=build/src/$(SRC)
comp:scripts/get-comp.sh $(B)
	$< $(SRC)

clean-comp::;rm -rf $(COMP_TARGET)

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
dist/bundle:scripts/bundle-dir.sh comp
	mkdir -pv $@
	$<

dist/cdn:cdn $(D)
	mkdir -pv $@
	cp -r $</* $@

dist/sbcl:sbcl $(D);
	mkdir -pv $@
	cp $(SBCL_TARGET)/src/runtime/sbcl $@
	cp $(SBCL_TARGET)/output/sbcl.core $@
	cp -r $(SBCL_TARGET)/contrib $@
	cd $(SBCL_TARGET) && ./clean.sh
	tar -I 'zstd' -cf $@/sbcl-source.tar.zst --exclude .git $(SBCL_TARGET)

dist/linux:linux $(D);

dist/rocksdb:rocksdb $(D);
	mkdir -pv $@
	cp -rf $(ROCKSDB_TARGET)/include/* $@
	cp -f $(ROCKSDB_TARGET)/librocksdb.* $@

dist/rust:rust-build $(D);
	cd $(RUST_TARGET) && x dist
dist/rust/bin:scripts/cargo-install.sh comp
	mkdir -pv $@
	$< "$(COMP_TARGET)/core/rust/app/cli/alik" "dist/rust"
	$< "$(COMP_TARGET)/core/rust/app/cli/krypt" "dist/rust"
	$< "$(COMP_TARGET)/core/rust/app/cli/tz" "dist/rust"
	$< "$(COMP_TARGET)/core/rust/app/cli/cc-init" "dist/rust"
	$< "$(COMP_TARGET)/core/rust/app/cli/mailman" "dist/rust"

dist/emacs:emacs-build $(D);

dist/lisp/fasl:scripts/sbcl-save-core.sh quicklisp-install
	mkdir -pv $@
	$< "$@/std.core"
	$< "$@/prelude.core" "(mapc #'ql:quickload \
	(list :nlp :rdb :organ :packy :skel :obj :net :parse :pod :dat :log :packy :rt :syn :xdb :doc :vc :rt))"

dist/lisp/bin:scripts/sbcl-make-bin.sh comp
	$< bin/skel
	cp $(COMP_TARGET)/core/lisp/app/bin/skel $@
	rm -f $(COMP_TARGET)/core/lisp/app/bin/skel.fasl
	$< bin/organ
	cp $(COMP_TARGET)/core/lisp/app/bin/organ $@
	rm -f $(COMP_TARGET)/core/lisp/app/bin/organ.fasl
	$< bin/homer
	cp $(COMP_TARGET)/core/lisp/app/bin/homer $@
	rm -f $(COMP_TARGET)/core/lisp/app/bin/homer.fasl
	$< bin/packy
	cp $(COMP_TARGET)/core/lisp/app/bin/packy $@
	rm -f $(COMP_TARGET)/core/lisp/app/bin/packy.fasl
	$< bin/rdb
	cp $(COMP_TARGET)/core/lisp/app/bin/rdb $@
	rm -f $(COMP_TARGET)/core/lisp/app/bin/rdb.fasl

dist/comp:comp
	mkdir -pv $@
	cp -r $(COMP_TARGET)/{org,core,infra,demo,nas-t} $@
clean-dist:;rm -rf $(D)
clean-build:;rm -rf $(B)

### Quickstart
quick:comp
