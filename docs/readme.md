# GNU / musl compilers by Dyne.org

## Introduction

This is a pre-built cross-compilation toolchain that combine the GNU
compiler collection (GCC with Binutils, GMP, MPC and MPFR) with the
musl C library. Pronounced "muscl", our C/C++ compiler packages are
optimized to be small in size and produce static binaries,
redistributed by the Dyne.org foundation.

Our goal is to provide x86 64-bit Linux hosts (including WSL2) with
ready to use cross-compilers that build static binaries for different
architectures without installing additional system packages or
fighting with distribution-specific patches.

## Usage

The hard-coded absolute path this toolchain resides is: `/opt/musl-dyne`

One should therefore include `/opt/musl-dyne/bin` in $PATH:
```sh
export PATH=/opt/musl-dyne/bin:$PATH
```

Look inside the bin directory for the list of executable compiler
tools and setup `CC`, `CXX` and `LD` flags accordingly for each build
system used by your projects.

## Source components

All sources are mirrored on [files.dyne.org](https://files.dyne.org/musl?dir=musl/sources)

The latest build is made with:

- binutils-2.44.tar.gz
- gcc-15.1.0.tar.xz
- gmp-6.1.2.tar.bz2
- linux-5.8.5.tar.xz
- mpc-1.1.0.tar.gz
- mpfr-4.0.2.tar.bz2
- musl-1.2.5.tar.gz

Build flags used: `--disable-nls --disable-libmudflap
--disable-libsanitizer`.  We omit debugging functions, but we enable
decimal-float, fixed-point, quadmath and lto, as well libitm to
satisfy advanced C++ requirements.

Builds are fully automated over CI and use semantic versioning that is
specific to dyne/musl and unrelated to gcc or musl release versions.

## Supported target architectures

We provide cross-compilers running on x86_64 and capable to target the
following architectures:

| name in docs  | file suffix | unix architecture name |
|---------------|-------------|------------------------|
| X86 64‑bit    | x86_64      | `x86_64-linux-musl`    |
| ARM 64‑bit    | arm_64      | `aarch64-linux-musl`   |
| ARM HF 32-bit | arm_hf      | `arm-linux-musleabihf` |
| RISC-V 64-bit | riscv_64    | `riscv64-linux-musl`   |

More target may be available in the future, get in touch with us if
you need:

- `aarch64[_be]-linux-musl`
- `i*86-linux-musl`
- `microblaze[el]-linux-musl`
- `mips-linux-musl`
- `mips[el]-linux-musl[sf]`
- `mips64[el]-linux-musl[n32][sf]`
- `powerpc-linux-musl[sf]`
- `powerpc64[le]-linux-musl`
- `s390x-linux-musl`
- `sh*[eb]-linux-musl[fdpic][sf]`
- `x86_64-linux-musl[x32]`

## Patches included

In addition to canonical musl support patches for GCC,
musl-cross-make's patch set provides:

- Static-linked PIE support
- Addition of `--enable-default-pie`
- Fixes for SH-specific bugs and bitrot in GCC
- Support for J2 Core CPU target in GCC & binutils
- SH/FDPIC ABI support


## License

All GNU software is licensed under the GNU GPL license.

We are very grateful to the
[musl-cross-make](https://github.com/richfelker/musl-cross-make)
project for its excellent work we build upon, its build tools and
documentation are licensed under the MIT/Expat license.

Each patch is distributed under the terms of the license of the
upstream project to which it is applied.

Resulting binary artifacts produced by our build retain the original
licensing from the upstream projects. The authors of musl-cross-make
or the Dyne.org foundation do not make any additional copyright claims
to these artifacts.

### Update

Unless you explicitly state otherwise, any contribution submitted for
inclusion shall be licensed as above without any additional terms or
conditions.

When updating to make a new release:

1. Check upstream updates https://github.com/richfelker/musl-cross-make and rebase if necessary
2. Update components in config.mak (defaults are in Makefile)
3. Run make to download sources/ from mirrors
4. Upload sources to files.dyne.org in musl/sources
5. Update `sources/download_from_dyne.sh` script
6. Prefix commit with semantic versioning (`fix:` or `feat:`)
