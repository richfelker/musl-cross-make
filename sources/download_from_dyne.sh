#!/bin/bash

# We redistribute the sources to overcome flaky mirrors upload to
# files.dyne.org after downloading with upstream's makefile and then
# scp all contents of sources subdir
DYNE="https://files.dyne.org/?file=musl/sources"

file="binutils-2.44.tar.gz"; echo "curl $file"; curl -L -o "$file" "${DYNE}/$file"
file="config.sub"; echo "curl $file"; curl -L -o "$file" "${DYNE}/$file"
file="gcc-14.2.0.tar.xz"; echo "curl $file"; curl -L -o "$file" "${DYNE}/$file"
file="gmp-6.1.2.tar.bz2"; echo "curl $file"; curl -L -o "$file" "${DYNE}/$file"
file="linux-headers-4.19.88-2.tar.xz"; echo "curl $file"; curl -L -o "$file" "${DYNE}/$file"
file="mpc-1.1.0.tar.gz"; echo "curl $file"; curl -L -o "$file" "${DYNE}/$file"
file="mpfr-4.0.2.tar.bz2"; echo "curl $file"; curl -L -o "$file" "${DYNE}/$file"
file="musl-1.2.5.tar.gz"; echo "curl $file"; curl -L -o "$file" "${DYNE}/$file"
