# GNU / musl compilers by Dyne.org

## For quick start go to [dyne.org/musl](https://dyne.org/musl)

This repository ships pre-built cross-compilation toolchains that
combine the GNU compiler collection (GCC with Binutils, GMP, MPC and
MPFR) with the musl C library.

The goal is to provide any developer on a x86 64-bit Linux host
(including WSL2) with binaries for different instruction sets without
installing additional system packages or fighting with
distribution-specific patches.

## Usage

The hard-coded absolute path this toolchain resides is: `/opt/musl-dyne`

One should therefore include `/opt/musl-dyne/bin` in $PATH:
```sh
export PATH=/opt/musl-dyne/bin:$PATH
```

Look inside the bin directory for the list of executable compiler tools and setup `CC` and `CXX` flags accordingly for each build system used by your projects.

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

### Contribution

Unless you explicitly state otherwise, any contribution submitted for
inclusion shall be licensed as above without any additional terms or
conditions.
