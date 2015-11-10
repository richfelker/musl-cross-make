
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
	--disable-libmudflap --disable-libsanitizer

GCC0_VARS = CFLAGS="-O0 -g0" CXXFLAGS="-O0 -g0"
GCC0_CONFIG = $(GCC_CONFIG) \
	--with-newlib --disable-libssp --disable-threads \
	--disable-shared --disable-libgomp --disable-libatomic \
	--disable-libquadmath --disable-decimal-float --disable-nls \
	--enable-languages=c

GCC0_BDIR = $(PWD)/gcc-$(GCC_VER)/build0/gcc
GCC0_CC = $(GCC0_BDIR)/xgcc -B $(GCC0_BDIR)

MUSL_CONFIG = CC="$(GCC0_CC)" --prefix=

-include config.mak


all: install_binutils install_musl install_gcc

clean:
	rm -rf gcc-$(GCC_VER) binutils-$(BINUTILS_VER) musl

distclean: clean
	rm -rf sources/config.sub sources/*.tar.bz2

.PHONY: extract_binutils extract_gcc clone_musl
.PHONY: configure_binutils configure_gcc0 configure_gcc configure_musl
.PHONY: build_binutils build_gcc0 build_gcc build_musl
.PHONY: install_binutils install_gcc install_musl

extract_binutils: binutils-$(BINUTILS_VER)/.mcm_extracted
extract_gcc: gcc-$(GCC_VER)/.mcm_extracted
clone_musl: musl/.mcm_cloned

configure_binutils: binutils-$(BINUTILS_VER)/.mcm_configured
configure_gcc0: gcc-$(GCC_VER)/build0/.mcm_configured
configure_gcc: gcc-$(GCC_VER)/build/.mcm_configured
configure_musl: musl/.mcm_configured

build_binutils: binutils-$(BINUTILS_VER)/.mcm_built
build_gcc0: gcc-$(GCC_VER)/build0/.mcm_built
build_gcc: gcc-$(GCC_VER)/build/.mcm_built
build_musl: musl/.mcm_built

install_binutils: binutils-$(BINUTILS_VER)/.mcm_installed
install_gcc: gcc-$(GCC_VER)/build/.mcm_installed
install_musl: musl/.mcm_installed




sources/config.sub:
	wget -O $@ 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD'

sources/binutils-%:
	wget -c -O $@.part $(BINUTILS_SITE)/$(notdir $@)
	mv $@.part $@

sources/gcc-%:
	wget -c -O $@.part $(GCC_SITE)/$(basename $(basename $(notdir $@)))/$(notdir $@)
	mv $@.part $@



binutils-$(BINUTILS_VER)/.mcm_extracted: sources/binutils-$(BINUTILS_VER).tar.bz2 sources/config.sub
	tar jxvf $<
	cat patches/binutils-$(BINUTILS_VER)/* | ( cd binutils-$(BINUTILS_VER) && patch -p1 )
	cp sources/config.sub binutils-$(BINUTILS_VER)
	touch $@

binutils-$(BINUTILS_VER)/.mcm_configured: binutils-$(BINUTILS_VER)/.mcm_extracted
	test -e binutils-$(BINUTILS_VER)/config.status || ( cd binutils-$(BINUTILS_VER) && ./configure $(BINUTILS_CONFIG) )
	touch $@

binutils-$(BINUTILS_VER)/.mcm_built: binutils-$(BINUTILS_VER)/.mcm_configured
	cd binutils-$(BINUTILS_VER) && $(MAKE)
	touch $@

binutils-$(BINUTILS_VER)/.mcm_installed: binutils-$(BINUTILS_VER)/.mcm_built
	cd binutils-$(BINUTILS_VER) && $(MAKE) install
	touch $@




gcc-$(GCC_VER)/.mcm_extracted: sources/gcc-$(GCC_VER).tar.bz2 sources/config.sub
	tar jxvf $<
	cat patches/gcc-$(GCC_VER)/* | ( cd gcc-$(GCC_VER) && patch -p1 )
	cp sources/config.sub gcc-$(GCC_VER)
	touch $@

gcc-$(GCC_VER)/build0/.mcm_configured: gcc-$(GCC_VER)/.mcm_extracted | binutils-$(BINUTILS_VER)/.mcm_installed
	mkdir -p gcc-$(GCC_VER)/build0
	test -e gcc-$(GCC_VER)/build0/config.status || ( cd gcc-$(GCC_VER)/build0 && $(GCC0_VARS) ../configure $(GCC0_CONFIG) )
	touch $@

gcc-$(GCC_VER)/build0/.mcm_built: gcc-$(GCC_VER)/build0/.mcm_configured
	cd gcc-$(GCC_VER)/build0 && $(MAKE)
	touch $@

gcc-$(GCC_VER)/build/.mcm_configured:  gcc-$(GCC_VER)/.mcm_extracted | binutils-$(BINUTILS_VER)/.mcm_installed musl/.mcm_installed
	mkdir -p gcc-$(GCC_VER)/build
	test -e gcc-$(GCC_VER)/build/config.status || ( cd gcc-$(GCC_VER)/build && ../configure $(GCC_CONFIG) )
	touch $@

gcc-$(GCC_VER)/build/.mcm_built: gcc-$(GCC_VER)/build/.mcm_configured
	cd gcc-$(GCC_VER)/build && $(MAKE)
	touch $@

gcc-$(GCC_VER)/build/.mcm_installed: gcc-$(GCC_VER)/build/.mcm_built
	cd gcc-$(GCC_VER)/build && $(MAKE) install
	touch $@





musl/.mcm_cloned:
	test -d musl || git clone -b $(MUSL_TAG) git://git.musl-libc.org/musl musl
	touch $@

musl/.mcm_configured: musl/.mcm_cloned gcc-$(GCC_VER)/build0/.mcm_built
	cd musl && ./configure $(MUSL_CONFIG)
	cat patches/musl-complex-hack >> musl/config.mak
	touch $@

musl/.mcm_built: musl/.mcm_configured
	cd musl && $(MAKE)
	touch $@

musl/.mcm_installed: musl/.mcm_built
	cd musl && $(MAKE) install DESTDIR=$(OUTPUT)/$(TARGET)
	ln -sfn . $(OUTPUT)/$(TARGET)/usr
	touch $@
