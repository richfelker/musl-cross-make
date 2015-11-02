
OUTPUT = $(PWD)/output
TARGET = sh2eb-linux-musl
SOURCES = sources

BINUTILS_VER = 2.25.1
GCC_VER = 5.2.0
MUSL_TAG = master

COMMON_CONFIG = --disable-werror \
	--target=$(TARGET) --prefix=$(OUTPUT) \
	--with-sysroot=$(OUTPUT)/$(TARGET)

BINUTILS_CONFIG = $(COMMON_CONFIG)
GCC_MULTILIB_CONFIG = --disable-multilib --with-multilib-list=
ifeq ($(TARGET),x86_64-x32-linux-musl)
GCC_MULTILIB_CONFIG = --with-multilib-list=mx32
endif
GCC_LANG_CONFIG = --enable-languages=c,c++,lto
GCC_CONFIG = $(COMMON_CONFIG) --enable-tls \
	--disable-libmudflap --disable-libsanitizer \
	--disable-libquadmath --disable-decimal-float \
	--with-target-libiberty=no --with-target-zlib=no \
	$(GCC_LANG_CONFIG) \
	$(GCC_MULTILIB_CONFIG)

ifeq ($(TARGET),powerpc-linux-musl)
GCC_CONFIG += --with-long-double-64
endif

GCC0_CONFIG = $(GCC_CONFIG) \
	--with-newlib --disable-libssp --disable-threads \
	--disable-shared --disable-libgomp --disable-libatomic \
	--disable-libquadmath --disable-decimal-float --disable-nls \
	--enable-languages=c \
	CFLAGS="-O0 -g0" CXXFLAGS="-O0 -g0"

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
	rm -rf $(SOURCES)/config.sub $(SOURCES)/*.tar.bz2

steps/configure_gcc0: steps/install_binutils
steps/configure_gcc: steps/install_musl


$(SOURCES)/config.sub:
	wget -O $@ 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD'

$(SOURCES)/binutils-%:
	wget -c -O $@.part http://ftp.gnu.org/pub/gnu/binutils/$(notdir $@)
	mv $@.part $@

$(SOURCES)/gcc-%:
	wget -c -O $@.part http://ftp.gnu.org/pub/gnu/gcc/$(basename $(basename $(notdir $@)))/$(notdir $@)
	mv $@.part $@



steps/extract_binutils: $(SOURCES)/binutils-$(BINUTILS_VER).tar.bz2 $(SOURCES)/config.sub
	tar jxvf $<
	cat patches/binutils-$(BINUTILS_VER)/* | ( cd binutils-$(BINUTILS_VER) && patch -p1 )
	cp $(SOURCES)/config.sub binutils-$(BINUTILS_VER)
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




steps/extract_gcc: $(SOURCES)/gcc-$(GCC_VER).tar.bz2 $(SOURCES)/config.sub
	tar jxvf $<
	cat patches/gcc-$(GCC_VER)/* | ( cd gcc-$(GCC_VER) && patch -p1 )
	cp $(SOURCES)/config.sub gcc-$(GCC_VER)
	touch $@

steps/configure_gcc0: steps/extract_gcc
	mkdir -p gcc-$(GCC_VER)/build0
	test -e gcc-$(GCC_VER)/build0/config.status || ( cd gcc-$(GCC_VER)/build0 && ../configure $(GCC0_CONFIG) )
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
