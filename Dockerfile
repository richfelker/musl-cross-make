FROM alpine as build
RUN apk add alpine-sdk make curl xz bison linux-headers
WORKDIR /src
COPY . /src

RUN make sources/gcc-13.2.0.tar.xz
RUN make sources/binutils-2.41.tar.xz
RUN make -j$(nproc) TARGET=aarch64-linux-musl 
RUN make install TARGET=aarch64-linux-musl


