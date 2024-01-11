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
    echo "-T: targets file path or targets string"
    echo "-C: use china mirror"
}

function ParseArgs() {
    while getopts "htT:C" arg; do
        case $arg in
        h)
            Help
            exit 0
            ;;
        t)
            TEST_BUILD_ONLY="1"
            ;;
        T)
            TARGETS_FILE="$OPTARG"
            ;;
        C)
            USE_CHINA_MIRROR="1"
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
    make TARGET="${TARGET}" \
        CONFIG_SUB_REV="28ea239c53a2" \
        GCC_VER="11.4.0" \
        MUSL_VER="1.2.4" \
        BINUTILS_VER="2.41" \
        GMP_VER="6.3.0" \
        MPC_VER="1.3.1" \
        MPFR_VER="4.2.1" \
        ISL_VER="" \
        LINUX_VER="" \
        MINGW_VER="v11.0.1" \
        CHINA="${USE_CHINA_MIRROR}" \
        'COMMON_CONFIG+=CFLAGS="-g0 -Os" CXXFLAGS="-g0 -Os" LDFLAGS="-s"' \
        'COMMON_CONFIG+=CC="gcc -static --static" CXX="g++ -static --static"' \
        'GCC_CONFIG+=--enable-languages=c,c++' \
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
riscv64-linux-musl
s390x-linux-musl
x86_64-linux-musl
x86_64-linux-muslx32
i486-w64-mingw32
i686-w64-mingw32
x86_64-w64-mingw32'

function BuildAll() {
    if [ "$TARGETS_FILE" ]; then
        if [ -f "$TARGETS_FILE" ]; then
            while read line; do
                if [ -z "$line" ] || [ "${line:0:1}" == "#" ]; then
                    continue
                fi
                Build "$line"
            done <"$TARGETS_FILE"
            return
        else
            TARGETS="$TARGETS_FILE"
        fi
    else
        TARGETS="$ALL_TARGETS"
    fi

    for line in $TARGETS; do
        if [ -z "$line" ] || [ "${line:0:1}" == "#" ]; then
            continue
        fi
        for target in ${line//,/ }; do
            Build "$target"
        done
    done
}

ChToScriptFileDir
Init
ParseArgs "$@"
BuildAll
