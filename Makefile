
OUTPUT = $(PWD)/output
TARGET = sh2eb-linux-musl

BINUTILS_VER = 2.25.1
GCC_VER = 5.2.0
MUSL_TAG = master

GNU_SITE = http://ftp.gnu.org/pub/gnu
GCC_SITE = $(GNU_SITE)/gcc
BINUTILS_SITE = $(GNU_SITE)/binutils

COMMON_CONFIG = --disable-werror \
	--target=$(TARGET) --prefix=$(OUTPUT) \
	--with-sysroot=$(OUTPUT)/$(TARGET)

BINUTILS_CONFIG = $(COMMON_CONFIG)
GCC_CONFIG = $(COMMON_CONFIG) --enable-tls \
	--disable-libmudflap --disable-libsanitizer \
	--disable-libquadmath --disable-decimal-float

GCC0_VARS = CFLAGS="-O0 -g0" CXXFLAGS="-O0 -g0"
GCC0_CONFIG = $(GCC_CONFIG) \
	--with-newlib --disable-libssp --disable-threads \
	--disable-shared --disable-libgomp --disable-libatomic \
	--disable-nls --enable-languages=c

GCC0_BDIR = $(PWD)/gcc-$(GCC_VER)/build0/gcc
GCC0_CC = $(GCC0_BDIR)/xgcc -B $(GCC0_BDIR)

MUSL_CONFIG = CC="$(GCC0_CC)" --prefix=

-include config.mak


all: steps/install_binutils steps/install_musl steps/install_gcc

clean:
	rm -rf gcc-$(GCC_VER) binutils-$(BINUTILS_VER) musl
	rm -rf steps/extract_* steps/clone_*
	rm -rf steps/configure_* steps/build_* steps/install_*

distclean: clean
	rm -rf sources/config.sub sources/*.tar.bz2

steps/configure_gcc0: steps/install_binutils
steps/configure_gcc: steps/install_musl


sources/config.sub:
	wget -O $@ 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD'

sources/binutils-%:
	wget -c -O $@.part $(BINUTILS_SITE)/$(notdir $@)
	mv $@.part $@

sources/gcc-%:
	wget -c -O $@.part $(GCC_SITE)/$(basename $(basename $(notdir $@)))/$(notdir $@)
	mv $@.part $@



steps/extract_binutils: sources/binutils-$(BINUTILS_VER).tar.bz2 sources/config.sub
	tar jxvf $<
	cat patches/binutils-$(BINUTILS_VER)/* | ( cd binutils-$(BINUTILS_VER) && patch -p1 )
	cp sources/config.sub binutils-$(BINUTILS_VER)
	touch $@

steps/configure_binutils: steps/extract_binutils
	test -e binutils-$(BINUTILS_VER)/config.status || ( cd binutils-$(BINUTILS_VER) && ./configure $(BINUTILS_CONFIG) )
	touch $@

steps/build_binutils: steps/configure_binutils
	cd binutils-$(BINUTILS_VER) && $(MAKE)
	touch $@

steps/install_binutils: steps/build_binutils
	cd binutils-$(BINUTILS_VER) && $(MAKE) install
	touch $@




steps/extract_gcc: sources/gcc-$(GCC_VER).tar.bz2 sources/config.sub
	tar jxvf $<
	cat patches/gcc-$(GCC_VER)/* | ( cd gcc-$(GCC_VER) && patch -p1 )
	cp sources/config.sub gcc-$(GCC_VER)
	touch $@

steps/configure_gcc0: steps/extract_gcc
	mkdir -p gcc-$(GCC_VER)/build0
	test -e gcc-$(GCC_VER)/build0/config.status || ( cd gcc-$(GCC_VER)/build0 && $(GCC0_VARS) ../configure $(GCC0_CONFIG) )
	touch $@

steps/build_gcc0: steps/configure_gcc0
	cd gcc-$(GCC_VER)/build0 && $(MAKE)
	touch $@

steps/configure_gcc: steps/extract_gcc
	mkdir -p gcc-$(GCC_VER)/build
	test -e gcc-$(GCC_VER)/build/config.status || ( cd gcc-$(GCC_VER)/build && ../configure $(GCC_CONFIG) )
	touch $@

steps/build_gcc: steps/configure_gcc
	cd gcc-$(GCC_VER)/build && $(MAKE)
	touch $@

steps/install_gcc: steps/build_gcc
	cd gcc-$(GCC_VER)/build && $(MAKE) install
	touch $@





steps/clone_musl:
	test -d musl || git clone -b $(MUSL_TAG) git://git.musl-libc.org/musl musl
	touch $@

steps/configure_musl: steps/clone_musl steps/build_gcc0
	cd musl && ./configure $(MUSL_CONFIG)
	cat patches/musl-complex-hack >> musl/config.mak
	touch $@

steps/build_musl: steps/configure_musl
	cd musl && $(MAKE)
	touch $@

steps/install_musl: steps/build_musl
	cd musl && $(MAKE) install DESTDIR=$(OUTPUT)/$(TARGET)
	ln -sfn . $(OUTPUT)/$(TARGET)/usr
	touch $@
