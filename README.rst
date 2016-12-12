ubuntu-grsec
============

This builds a grsec-enabled kernel for Ubuntu. It is based on the
configuration from a current Ubuntu Server based system (whatever
`laptop-salt <https://github.com/kisom/laptop-salt>`_ is configured to
use) using whatever kernel is currently supported by the grsecurity
patches in this repo. It's probably of limited use to anyone else.

The manual way
--------------

1. Fetch the testing grsec patches from https://grsecurity.net/.
2. Fetch the appropriate kernel from https://kernel.org/.
3. Copy the config from /boot/config-$(uname -r).
4. Extract the kernel.
5. Patch the kernel (cd kernel_tree && patch -p1 ../grsecurity*.patch).
   Note that only one grsecurity patch should be in this repo's working
   directory at any given time. Revision history exists for a reason.
6. Copy the config to kernel_tree/.config.
7. cd kernel_tree && make oldconfig to update the config file.
8. make menuconfig to configure grsec.
9. make && sudo make modules_install install.
10. ???
11. PROFIT[1]_

.. [1] Profit is, of course, a synonym of "weep for the things we've
   lost."


The Makefile way
----------------

NB: you may have to do some of the updating by hand. Also, upstream grsec
patches tend not to stick around, which is why they are kept in this repo.

1. make
2. sudo make install


Signing key
-----------

The signing key is my traffic key from my `key site <https://keys.kyleisom.net/>`_.::

	pub   4096R/0x9DEA9987AE305ED4 2015-09-16 [expires: 2020-09-14]
	uid                            Kyle Isom <kyle@imap.cc>
	uid                            Kyle Isom <kyle@tyrfingr.is>
	uid                            Kyle Isom <coder@kyleisom.net>
	uid                            Kyle Isom <isomk@kyleisom.net>
	uid                            Kyle Isom <kyle@metacircular.net>
	sub   4096R/0xB40E03E26F9AB6AE 2015-09-16 [expires: 2020-09-14]
