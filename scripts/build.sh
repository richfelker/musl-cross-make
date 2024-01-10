#!/bin/bash

function ChToScriptFileDir() {
    cd "$(dirname "$0")"
    if [ $? -ne 0 ]; then
        echo "cd to script file dir error"
        exit 1
    fi
}

function Init() {
    cd ..
    DIST="dist"
    mkdir -p "$DIST"
    if [ $? -ne 0 ]; then
        echo "mkdir dist dir ${DIST} error"
        exit 1
    fi
}

function Help() {
    echo "-h: help"
    echo "-t: test build only"
}

function ParseArgs() {
    while getopts "ht" arg; do
        case $arg in
        h)
            Help
            exit 0
            ;;
        t)
            TEST_BUILD_ONLY="1"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
            ;;
        esac
    done
}

function Build() {
    TARGET="$1"
    make TARGET=${TARGET} GCC_VER="11.4.0" \
        MUSL_VER="1.2.4" \
        BINUTILS_VER="2.41" \
        GMP_VER="6.3.0" \
        MPC_VER="1.3.1" \
        MPFR_VER="4.2.1" \
        ISL_VER="" \
        LINUX_VER="" \
        'COMMON_CONFIG+=CFLAGS="-g0 -Os" CXXFLAGS="-g0 -Os" LDFLAGS="-s"' \
        'BINUTILS_CONFIG+=--enable-compressed-debug-sections=none' \
        install
    if [ $? -ne 0 ]; then
        echo "build ${TARGET} error"
        exit 1
    fi
    if [ ! "$TEST_BUILD_ONLY" ]; then
        tar -zcvf ${DIST}/${TARGET}.tgz output/*
        if [ $? -ne 0 ]; then
            echo "package ${TARGET} error"
            exit 1
        fi
    fi
    rm -rf output/*
    rm -rf build/*
}

ALL_TARGETS='aarch64-linux-musl
arm-linux-musleabi
arm-linux-musleabihf
armv5-linux-musleabi
armv5-linux-musleabihf
armv6-linux-musleabi
armv6-linux-musleabihf
armv7-linux-musleabi
armv7-linux-musleabihf
i486-linux-musl
i686-linux-musl
mips-linux-musl
mips-linux-muslsf
mips-linux-musln32sf
mips64-linux-musl
mips64-linux-musln32
mips64-linux-musln32sf
mips64el-linux-musl
mips64el-linux-musln32
mips64el-linux-musln32sf
mipsel-linux-musl
mipsel-linux-musln32
mipsel-linux-musln32sf
mipsel-linux-muslsf
powerpc-linux-musl
powerpc-linux-muslsf
powerpc64-linux-musl
powerpc64le-linux-musl
powerpcle-linux-musl
powerpcle-linux-muslsf
riscv32-linux-musl
riscv64-linux-musl
s390x-linux-musl
x86_64-linux-musl
x86_64-linux-muslx32'

function BuildAll() {
    # while read line; do
    #     if [ -z "$line" ] || [ "${line:0:1}" == "#" ]; then
    #         continue
    #     fi
    #     Build "$line"
    # done <scripts/triples.txt

    for line in $ALL_TARGETS; do
        if [ -z "$line" ] || [ "${line:0:1}" == "#" ]; then
            continue
        fi
        Build "$line"
    done
}

ChToScriptFileDir
Init
ParseArgs "$@"
BuildAll
