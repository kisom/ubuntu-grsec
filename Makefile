KERNEL_VERSION :=		4.8.14
GRSEC_PATCHFILE :=		grsecurity-3.1-4.8.14-201612110933.patch
GRSEC_UPSTREAM :=		https://grsecurity.net/test/$(GRSEC_PATCHFILE)
GRSEC_SIG :=			$(GRSEC_PATCHFILE).sig
GRSEC_SIG_UPSTREAM :=		$(GRSEC_UPSTREAM).sig
KERNEL_TARBALL :=		linux-$(KERNEL_VERSION).tar.xz
KERNEL_UPSTREAM :=		https://cdn.kernel.org/pub/linux/kernel/v4.x/$(KERNEL_TARBALL)
KERNEL_TREE :=			linux-$(KERNEL_VERSION)

.PHONY: all
all: $(KERNEL_TREE)/vmlinux

.PHONY: download
download: fetch verify

.PHONY: fetch
fetch: $(GRSEC_PATCHFILE) $(KERNEL_TARBALL)

.PHONY: verify
verify:
	sha512sum -c manifest
	gpg --quiet --verify $(GRSEC_SIG)

.PHONY: update-manifest
update-manifest:
	curl -f -L -o $(GRSEC_PATCHFILE) $(GRSEC_UPSTREAM)
	curl -f -L -o $(GRSEC_SIG) $(GRSEC_SIG_UPSTREAM)
	curl -f -C- -L -o $(KERNEL_TARBALL) $(KERNEL_UPSTREAM)
	sha512sum $(GRSEC_PATCHFILE) $(GRSEC_SIG_UPSTREAM) $(KERNEL_TARBALL) config | tee manifest

$(GRSEC_PATCHFILE): $(GRSEC_SIG)
	curl -L -o $@ $(GRSEC_UPSTREAM)
	grep $@ manifest | sha512sum -c -

$(GRSEC_SIG):
	curl -L -o $@ $(GRSEC_SIG_UPSTREAM)
	grep $@ manifest | sha512sum -c -

$(KERNEL_TARBALL):
	curl -L -o $@ $(KERNEL_UPSTREAM)
	grep $@ manifest | sha512sum -c -

$(KERNEL_TREE): $(KERNEL_TARBALL)
	tar Jxf $<

# This target should only be used in testing.
.PHONY: apply-grsecurity-patch
apply-grsecurity-patch: $(KERNEL_TREE)/grsecurity/Makefile

$(KERNEL_TREE)/grsecurity/Makefile: $(KERNEL_TREE) $(GRSEC_PATCHFILE) $(GRSEC_SIG)
	grep grsec manifest | sha512sum -c -
	gpg --quiet --verify $(GRSEC_SIG)
	cd $(KERNEL_TREE) && patch -p1 < ../$(GRSEC_PATCHFILE)

$(KERNEL_TREE)/.config: $(KERNEL_TREE) $(KERNEL_TREE)/grsecurity/Makefile
	cp config $@

$(KERNEL_TREE)/vmlinux: $(KERNEL_TREE)/.config $(KERNEL_TREE)/grsecurity/Makefile
	cd $(KERNEL_TREE) && make

install: $(KERNEL_TREE)/vmlinux
	cd $(KERNEL_TREE) && make modules_install install

.PHONY: clean
clean:
	rm -fr $(KERNEL_TREE)
