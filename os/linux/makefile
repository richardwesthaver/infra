### infra/os/linux/makefile --- Linux builder

### Code:
LINUX_TARGET:=linux-$(LINUX_VERSION)
all:$(LINUX_TARGET) config
$(LINUX_TARGET):scripts/get-linux.sh;
	mkdir -pv build/$@
	gpg --export autosigner@ torvalds@ gregkh@ > build/$@/keyring.gpg
	$< $(LINUX_VERSION) build $(abspath build/$@/keyring.gpg)
	unxz build/$@.tar.xz && tar -xvf build/$@.tar
config:build/$(LINUX_TARGET);
	cd $< && make mrproper -j && zcat /proc/config.gz > .config && make localmodconfig
clean::;rm -rf build/$(LINUX_TARGET) build/$(LINUX_TARGET).* build/linux-tarball-verify.*
