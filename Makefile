KERNEL_VERSION :=		4.8.14
GRSEC_PATCHFILE :=		grsecurity-3.1-4.8.14-201612110933.patch
GRSEC_UPSTREAM :=		https://grsecurity.net/test/$(GRSEC_PATCHFILE)
GRSEC_SIG :=			$(GRSEC_PATCHFILE).sig
GRSEC_SIG_UPSTREAM :=		$(GRSEC_UPSTREAM).sig
KERNEL_TARBALL :=		linux-$(KERNEL_VERSION).tar
KERNEL_TARXZ :=			$(KERNEL_TARBALL).xz
KERNEL_SIG :=			$(KERNEL_TARBALL).sign
KERNEL_UPSTREAM :=		https://cdn.kernel.org/pub/linux/kernel/v4.x/$(KERNEL_TARBALL).xz
KERNEL_SIG_UPSTREAM :=		https://cdn.kernel.org/pub/linux/kernel/v4.x/$(KERNEL_TARBALL).sign
KERNEL_TREE :=			linux-$(KERNEL_VERSION)

.PHONY: all
all: $(KERNEL_TREE)/vmlinux

print-%: ; @echo $*=$($*)

.PHONY: download
download: fetch verify

.PHONY: fetch
fetch: $(GRSEC_PATCHFILE) $(KERNEL_TARBALL)

.PHONY: verify
verify:
	sha512sum -c manifest
	gpg --quiet --verify $(GRSEC_SIG)
	gpg --quiet --verify $(KERNEL_SIG)

.PHONY: update-manifest
update-manifest:
	test -f $(GRSEC_PATCHFILE) || curl -f -L -o $(GRSEC_PATCHFILE) $(GRSEC_UPSTREAM)
	test -f $(GRSEC_SIG)       || curl -f -L -o $(GRSEC_SIG) $(GRSEC_SIG_UPSTREAM)
	test -f $(KERNEL_TARXZ)    || curl -f -C- -L -o $(KERNEL_TARXZ) $(KERNEL_UPSTREAM)
	test -f $(KERNEL_SIG)      || curl -f -C- -L -o $(KERNEL_SIG) $(KERNEL_SIG_UPSTREAM)
	gpg --quiet --verify $(GRSEC_SIG)
	test -f $(KERNEL_TARBALL) || xz -d -k $(KERNEL_TARXZ)
	gpg --quiet --verify $(KERNEL_SIG)
	sha512sum $(GRSEC_PATCHFILE) $(GRSEC_SIG) $(KERNEL_TARXZ) $(KERNEL_SIG) config | tee manifest

$(GRSEC_PATCHFILE): $(GRSEC_SIG)
	test -f $@ || curl -L -o $@ $(GRSEC_UPSTREAM)
	grep $@ manifest | sha512sum -c -

$(GRSEC_SIG):
	test -f $@ || curl -L -o $@ $(GRSEC_SIG_UPSTREAM)
	grep $@ manifest | sha512sum -c -

$(KERNEL_TARBALL): $(KERNEL_TARXZ) $(KERNEL_SIG)
	test -f $@ || xz -d $(KERNEL_TARXZ)
	gpg --quiet --verify $(KERNEL_SIG)

$(KERNEL_TARXZ):
	test -f $@ || curl -L -o $@ $(KERNEL_UPSTREAM)
	grep $@ manifest | sha512sum -c -

$(KERNEL_SIG):
	test -f $@ || curl -L -o $@ $(KERNEL_SIG_UPSTREAM)
	grep $@ manifest | sha512sum -c -

$(KERNEL_TREE): $(KERNEL_TARBALL)
	test -d $@ || tar xf $<

# This target should only be used in testing.
.PHONY: apply-grsecurity-patch
apply-grsecurity-patch: $(KERNEL_TREE)/grsecurity/Makefile

$(KERNEL_TREE)/grsecurity/Makefile: $(KERNEL_TREE) $(GRSEC_PATCHFILE) $(GRSEC_SIG)
	grep grsec manifest | sha512sum -c -
	gpg --quiet --verify $(GRSEC_SIG)
	test -f $@ || ( cd $(KERNEL_TREE) && patch -p1 < ../$(GRSEC_PATCHFILE) )

$(KERNEL_TREE)/.config: $(KERNEL_TREE) $(KERNEL_TREE)/grsecurity/Makefile
	cp config $@

$(KERNEL_TREE)/vmlinux: $(KERNEL_TREE)/.config $(KERNEL_TREE)/grsecurity/Makefile
	cd $(KERNEL_TREE) && make

install: $(KERNEL_TREE)/vmlinux
	cd $(KERNEL_TREE) && make modules_install install

.PHONY: clean
clean:
	rm -fr $(KERNEL_TREE) $(KERNEL_TARBALL)

# If you want to trust these keys, you'll need to
# gpg2 --edit <key id>
# gpg2 --lsign <key id>
.PHONY: fetch-keys
fetch-keys:
	@echo "Fetching and importing keys."
	@echo "*** ACTION REQUIRED ***"
	@echo "This Makefile will *not* update the trust on the keys."
	@sleep 2
	# Fetch GKH's release public key.
	gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 38DBBDC86092693E
	# Fetch LT's release public key.
	gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 79BE3E4300411886
	# Fetch spender's release public key.
	gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 44D1C0F82525FE49
