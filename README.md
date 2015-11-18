musl-cross-make
===============

This is a quick and simple makefile-based alternative for producing
musl-based cross compilers. The current focus is on SH2/J2 Core
targets and NOMMU (where PIE or FDPIC is mandatory) since these are
not adequately supported by other musl cross-compiler toolchain build
systems, but all musl-supported targets are intended to work.

In addition to the build system, musl-cross-make provides a number of
patches, including:

- Updated versions of the musl target patches going into upstream GCC
- Static-PIE support and optionally defaulting to PIE
- Fixes for SH-specific bugs and bitrot in GCC
- Support for J2 Core CPU target in GCC & binutils
- SH/FDPIC ABI support

Most of these patches are integrated in gcc trunk/binutils master.
They should also be usable with Gregor's original musl-cross or other
build systems, if desired.

Some functionality (SH/FDPIC, and support for J2 specific features) is
presently only available with gcc 5.2.0 and binutils 2.25.1.


Usage
-----

The build system make be configured by providing a config.mak file in
the top-level directory. The only mandatory variable is TARGET, which
should contain a gcc target tuple (such as sh2eb-linux-musl), but many
more options are available. The top-level config.mak.dist file shows
examples, and several full configurations are available in presets/*.

For recent gcc versions that need gmp/mpfr/mpc, suitable versions need
to be installed in the default library path, or the appropriate --with
configure options need to be added to GCC_CONFIG in config.mak so that
the gcc configure process can find them.

After setting up config.mak, simply run make. Parallel builds are
supported.

The resulting toolchain will be placed ./output by default, or the
OUTPUT directory specified in config.mak. It is sysrooted and can be
freely moved to a different location.
