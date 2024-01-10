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

function Build() {
    TARGET="$1"
    make TARGET=${TARGET} GCC_VER="11.4.0" \
        MUSL_VER="1.2.4" \
        BINUTILS_VER="2.40" \
        GMP_VER="6.3.0" \
        MPC_VER="1.3.1" \
        MPFR_VER="4.2.1" \
        ISL_VER="" \
        LINUX_VER="" \
        'COMMON_CONFIG+=CFLAGS="-g0 -Os" CXXFLAGS="-g0 -Os" LDFLAGS="-s"' \
        install
    if [ $? -ne 0 ]; then
        echo "build ${TARGET} error"
        exit 1
    fi
    rm -rf output/${TARGET}
    tar -zcvf ${DIST}/${TARGET}.tgz output/*
    if [ $? -ne 0 ]; then
        echo "package ${TARGET} error"
        exit 1
    fi
    rm -rf output/*
}

function BuildAll() {
    while read line; do
        if [ -z "$line" ] || [ "${line:0:1}" == "#" ]; then
            continue
        fi
        Build "$line"
    done <scripts/triples.txt
}

ChToScriptFileDir
Init
BuildAll
