musl-cross-make
===============

This is a quick and simple makefile-based alternative for producing
musl-based cross compilers. In addition to the build system, it
provides a number of patches, including:

- Updated versions of the musl target patches going into upstream GCC

- Static-PIE support and enabling PIE as default

- Fixes for SH-specific bugs and bitrot in GCC

- Support for J2 Core CPU target in GCC & binutils

The current focus is on SH2/J2 Core targets and NOMMU (where PIE is
mandatory) since these are not adequately supported by other musl
cross-compiler toolchain build systems.

Usage
-----

To build, copy the provided config.mak.dist to config.mak and edit
then run make. Parallel builds are supported. The host needs to have
suitable gmp/mpfr/mpc libraries installed in the standard library
path, or you can add the appropriate --with options to GCC_CONFIG.

At present only GCC 5.2.0 and Binutils 2.25.1 are supported.
Backporting of patches is needed to support other versions.

The included patches should also be usable with Gregor's original
musl-cross or other build systems, if desired.
