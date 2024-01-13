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
    echo "-a: enable archive"
    echo "-t: test build only"
    echo "-T: targets file path or targets string"
    echo "-C: use china mirror"
    echo "-c: set CC"
    echo "-x: set CXX"
    echo "-f: set FC"
    echo "-s: static build"
    echo "-n: with native build"
    echo "-e: skip error (-Wno-error)"
}

function ParseArgs() {
    while getopts "hatT:Cc:x:f:sne" arg; do
        case $arg in
        h)
            Help
            exit 0
            ;;
        a)
            ENABLE_ARCHIVE="1"
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
        c)
            CC="$OPTARG"
            ;;
        x)
            CXX="$OPTARG"
            ;;
        f)
            FC="$OPTARG"
            ;;
        s)
            STATIC_BUILD="1"
            ;;
        n)
            NATIVE_BUILD="1"
            ;;
        e)
            SKIP_ERROR="1"
            ;;
        ?)
            echo "unkonw argument"
            exit 1
            ;;
        esac
    done
}

function FixArgs() {
    if [ "$SKIP_ERROR" ]; then
        FLAG="${FLAG} -Wno-error"
    fi
    mkdir -p "${DIST}"
    if [ $? -ne 0 ]; then
        echo "mkdir dist dir ${DIST} error"
        exit 1
    fi
    DIST="$(cd "$DIST" && pwd)"
    if [ $? -ne 0 ]; then
        echo "cd dist dir ${DIST} error"
        exit 1
    fi
}

function Build() {
    TARGET="$1"
    DIST_NAME="${DIST}/${TARGET}"
    NATIVE_DIST_NAME="${DIST_NAME}-native"

    make \
        TARGET="${TARGET}" \
        OUTPUT="${DIST_NAME}" \
        install
    if [ $? -ne 0 ]; then
        echo "build ${TARGET} error"
        exit 1
    fi

    if [ "$NATIVE_BUILD" ]; then
        PATH="${DIST_NAME}/bin:${PATH}" \
            make \
            TARGET="${TARGET}" \
            OUTPUT="${NATIVE_DIST_NAME}" \
            NATIVE=true \
            install
    fi
    if [ "$TEST_BUILD_ONLY" ]; then
        rm -rf "${DIST_NAME}" "${NATIVE_DIST_NAME}"
    else
        if [ "$ENABLE_ARCHIVE" ]; then
            tar -zcvf "${DIST_NAME}.tgz" -C "${DIST_NAME}" .
            if [ $? -ne 0 ]; then
                echo "package ${DIST_NAME} error"
                exit 1
            fi

            if [ "$NATIVE_BUILD" ]; then
                tar -zcvf "${NATIVE_DIST_NAME}.tgz" -C "${NATIVE_DIST_NAME}" .
                if [ $? -ne 0 ]; then
                    echo "package ${NATIVE_DIST_NAME} error"
                    exit 1
                fi
            fi
            rm -rf "${DIST_NAME}" "${NATIVE_DIST_NAME}"
        fi
    fi
    make clean
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

FLAG="-g0 -O2"

function BuildAll() {
    cat >config.mak <<EOF
CONFIG_SUB_REV = 28ea239c53a2
GCC_VER = 11.4.0
MUSL_VER = 1.2.4
BINUTILS_VER = 2.41
GMP_VER = 6.3.0
MPC_VER = 1.3.1
MPFR_VER = 4.2.1
ISL_VER = 
LINUX_VER = 5.15.2
MINGW_VER = v11.0.1

CC_COMPILER = ${CC}
CXX_COMPILER = ${CXX}
FC_COMPILER = ${FC}
CHINA = ${USE_CHINA_MIRROR}
STATIC = ${STATIC_BUILD}

COMMON_CONFIG += CFLAGS="-g0 -O2" CXXFLAGS="-g0 -O2"
GCC_CONFIG += --enable-languages=c,c++
BINUTILS_CONFIG += --enable-compressed-debug-sections=none
COMMON_CONFIG += --disable-nls
GCC_CONFIG += --disable-libquadmath --disable-decimal-float
GCC_CONFIG += --disable-libitm
GCC_CONFIG += --disable-fixed-point
GCC_CONFIG += --disable-lto

EOF
    if [ "$STATIC_BUILD" ]; then
        echo 'COMMON_CONFIG += LDFLAGS="-s -static --static"' >>config.mak
    else
        echo 'COMMON_CONFIG += LDFLAGS="-s"' >>config.mak
    fi
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
FixArgs
BuildAll
