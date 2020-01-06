musl-cross-make
===============

This is the second generation of musl-cross-make, a fast, simple,
but advanced makefile-based approach for producing musl-targeting
cross compilers. Features include:

- Single-stage GCC build, used to build both musl libc and its own
  shared target libs depending on libc.

- No hard-coded absolute paths; resulting cross compilers can be
  copied/moved anywhere.

- Ability to build multiple cross compilers for different targets
  using a single set of patched source trees.

- Nothing is installed until running `make install`, and the
  installation location can be chosen at install time.

- Automatic download of source packages, including GCC prerequisites
  (GMP, MPC, MPFR), using https and checking hashes.

- Automatic patching with canonical musl support patches and patches
  which provide bug fixes and features musl depends on for some arch
  targets.


Usage
-----

The build system can be configured by providing a `config.mak` file in
the top-level directory. The only mandatory variable is `TARGET`, which
should contain a gcc target tuple (such as `i486-linux-musl`), but many
more options are available. See the provided `config.mak.dist` and
`presets/*` for examples.

To compile, run `make`. To install to `$(OUTPUT)`, run `make install`.

The default value for `$(OUTPUT)` is output; after installing here you
can move the cross compiler toolchain to another location as desired.



Supported `TARGET`s
-------------------

The following is a non-exhaustive list of `$(TARGET)` tuples that are
believed to work:

- `aarch64[_be]-linux-musl`
- `arm[eb]-linux-musleabi[hf]`
- `i*86-linux-musl`
- `microblaze[el]-linux-musl`
- `mips-linux-musl`
- `mips[el]-linux-musl[sf]`
- `mips64[el]-linux-musl[n32][sf]`
- `powerpc-linux-musl[sf]`
- `powerpc64[le]-linux-musl`
- `riscv64-linux-musl`
- `s390x-linux-musl`
- `sh*[eb]-linux-musl[fdpic][sf]`
- `x86_64-linux-musl[x32]`



How it works
------------

The current musl-cross-make is factored into two layers:

1. The top-level Makefile which is responsible for downloading,
   verifying, extracting, and patching sources, and for setting up a
   build directory, and

2. Litecross, the cross compiler build system, which is itself a
   Makefile symlinked into the build directory.

Most of the real magic takes place in litecross. It begins by setting
up symlinks to all the source trees provided to it by the caller, then
builds a combined `src_toolchain` directory of symlinks that combines
the contents of the top-level gcc and binutils source trees and
symlinks to gmp, mpc, and mpfr. One configured invocation them
configures all the GNU toolchain components together in a manner that
does not require any of them to be installed in order for the others
to use them.

Rather than building the whole toolchain tree at once, though,
litecross starts by building just the gcc directory and its
prerequisites, to get an `xgcc` that can be used to configure musl. It
then configures musl, installs musl's headers to a staging "build
sysroot", and builds `libgcc.a` using those headers. At this point it
has all the prerequisites to build musl `libc.a` and `libc.so`, which the
rest of the gcc target-libs depend on; once they are built, the full
toolchain `make all` can proceed.

Litecross does not actually depend on the musl-cross-make top-level
build system; it can be used with any pre-extracted, properly patched
set of source trees.


Project scope and goals
-----------------------

The primary goals of this project are to:

- Provide canonical musl support patches for GCC and binutils.

- Serve as a canonical example of how GCC should be built to target
  musl.

- Streamline the production of musl-targeting cross compilers so that
  musl users can easily produce musl-linked applications or bootstrap
  new systems using musl.

- Assist musl and toolchain developers in development and testing.

While the patches applied to GCC and binutils are all intended not to
break non-musl configurations, musl-cross-make itself is specific to
musl. Changes to add support for exotic target variants outside of
what upstream musl supports are probably out-of-scope unless they are
non-invasive. Changes to fix issues building musl-cross-make to run on
non-Linux systems are well within scope as long as they are clean.

Most importantly, this is a side project to benefit musl and its
users. It's not intended to be something high-maintenance or to divert
development effort away from musl itself.


Patches included
----------------

In addition to canonical musl support patches for GCC,
musl-cross-make's patch set provides:

- Static-linked PIE support
- Addition of `--enable-default-pie`
- Fixes for SH-specific bugs and bitrot in GCC
- Support for J2 Core CPU target in GCC & binutils
- SH/FDPIC ABI support

Most of these patches are integrated in gcc trunk/binutils master.
They should also be usable with Gregor's original musl-cross or other
build systems, if desired.

Some functionality (SH/FDPIC, and support for J2 specific features) is
presently only available with gcc 5.2.0 and later, and binutils 2.25.1
and later.

License
-------

The musl-cross-make build tools and documentation are licensed under
the MIT/Expat license as found in the `LICENSE` file.

Note that this license does not cover the patches (`patches/`) or
resulting binary artifacts.

Each patch (`patches/`) is distributed under the terms of the license
of the upstream project to which it is applied.

Similarly, any resulting binary artifacts produced using this build
tooling retain the original licensing from the upstream projects.  The
authors of musl-cross-make do not make any additional copyright claims
to these artifacts.

### Contribution

Unless you explicitly state otherwise, any contribution submitted for
inclusion in musl-cross-make by you shall be licensed as above without
any additional terms or conditions.
