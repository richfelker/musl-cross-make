FROM alpine
RUN apk add alpine-sdk make curl xz bison
WORKDIR /src
COPY . /src

RUN make sources/gcc-13.2.0.tar.xz
RUN make sources/binutils-2.41.tar.xz
RUN make TARGET=aarch64-linux-musl
