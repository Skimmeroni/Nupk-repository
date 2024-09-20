# Repository
A repository of installation scripts. I have written these with [Nupk](https://github.com/Skimmeroni/Nupk) in mind,
but can also work on their own.

The scripts are defined to be as unopinionated as possible.
These are the guidelines:

+ Strive for minimalism
+ Prefix is /usr
+ Libraries are compiled in both static and dynamic fashion whenever possible
+ Binaries and libraries are stripped
+ Binaries are built as static when needed
+ System libraries are used whenever possible, instead of local copies
+ LICENSE files will be installed (unless I forget to). The location is /usr/share/LICENSES
+ Init scripts are tailored for runit
+ Man pages are built only if the requirements are not cursed (e.g. Perl)
+ Fonts are installed to /usr/share/fonts/TTF or /usr/share/fonts/OTF
+ Some files will always be removed, such as
  + Libtool files, unless necessary (e.g. ImageMagick)
  + Examples
  + Man3 files
  + Documentation (it's a very specific use case)
  + Info files (use man pages, duh)
  + Aclocal files (are needed only for autotools which we don't use)
+ All tests are disabled
+ No NLS (Native Language Support)
+ No ACL (Access Control List)
+ Wayland instead of X

Of course, you are free to fork the repo and change it as you please.

# What if I want to build a linux system out of these?
At the very least, you'll need:

awk, bc, binutils, bison, bzip2, ca-certificates, curl, dhcpcd, diff,
findutils, flex, gcc, git, grep, init-scripts, iproute2, libedit, libgmp,
libmpc, libmpfr, libressl, linux-headers, m4, make, mdevd, mime-types,
musl, nextvi, nupk, oksh, patch, perl, pigz, runit, sbase, sed, skalibs,
skeleton, tzdata, ubase, util-linux, xz, zlib

You should also build and install a (linux?) kernel and a bootloader.
