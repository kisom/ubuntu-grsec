ubuntu-grsec
============

This builds a grsec-enabled kernel for Ubuntu. It is based on the
configuration from a current Ubuntu Server based system (whatever
`laptop-salt <https://github.com/kisom/laptop-salt>`_ is configured to
use) using whatever kernel is currently supported by the grsecurity
patches in this repo. It's probably of limited use to anyone else.

Current versions:

+==============+===========================+
| Component    | Version                   |
+==============+===========================+
| Distribution | Ubuntu Server 16.04.1 LTS |
+--------------+---------------------------+
| Linux kernel | 4.8.14                    |
+--------------+---------------------------+
| grsecurity   | testing-201612110933      |
+--------------+---------------------------+


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

Signatures are done on releases, and on key updates to the README. It
is safe to assume that the traffic key list on the key site is the key
that is used to sign updates.

Subcomponent signing keys
^^^^^^^^^^^^^^^^^^^^^^^^^

The kernel tar file and grsec patch file both have signatures that are
checked. Additionally, a SHA-512 digest for each of these is checked,
as are the SHA-512 digests on the signature files. These files should
also be verified before committing; the tag signature attests to the
verification on the repo side.

grsecurity::

  pub   4096R/0x44D1C0F82525FE49 2013-11-10
  uid                            Bradley Spengler (spender) <spender@grsecurity.net>
  sub   4096R/0x4151B7C93F57788A 2013-11-10

linux::

  pub   4096R/0x38DBBDC86092693E 2011-09-23
  uid                            Greg Kroah-Hartman (Linux kernel stable release signing key) <greg@kroah.com>
  sub   4096R/0xF38153E276D54749 2011-09-23
  
  pub   2048R/0x79BE3E4300411886 2011-09-20
  uid                            Linus Torvalds <torvalds@linux-foundation.org>
  sub   2048R/0x88BCE80F012F54CA 2011-09-20

