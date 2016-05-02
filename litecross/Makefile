
OUTPUT = $(PWD)/output

BINUTILS_SRCDIR = BINUTILS_SRCDIR_not_set
GCC_SRCDIR = GCC_SRCDIR_not_set
MUSL_SRCDIR = MUSL_SRCDIR_not_set

COMMON_CONFIG = 
GCC_CONFIG = $(COMMON_CONFIG) 
TOOLCHAIN_CONFIG = $(GCC_CONFIG)

XGCC_DIR = ../obj_toolchain/gcc
XGCC = $(XGCC_DIR)/xgcc -B $(XGCC_DIR)
MUSL_CONFIG = CC="$(XGCC)" LIBCC="../obj_toolchain/$(TARGET)/libgcc/libgcc.a" --prefix=

-include config.mak

MAKE += INFO_DEPS=

FULL_TOOLCHAIN_CONFIG = $(TOOLCHAIN_CONFIG) \
	--disable-werror \
	--target=$(TARGET) --prefix= \
	--with-sysroot=/$(TARGET) \
	--with-build-sysroot='$$(LC_ROOT)/obj_sysroot' \
	--enable-tls \
	--disable-libmudflap --disable-libsanitizer

MUSL_VARS = AR=../obj_toolchain/binutils/ar RANLIB=../obj_toolchain/binutils/ranlib

ifeq ($(TARGET),)

all:
	@echo TARGET must be set.
	@exit 1

install: all

else

all: musl toolchain

install: install-musl install-toolchain

musl: obj_musl/.lc_built

toolchain: obj_toolchain/.lc_built

.PHONY: all musl toolchain install-musl install-toolchain clean

src_binutils: | $(BINUTILS_SRCDIR)
	ln -sf $(BINUTILS_SRCDIR) $@

src_gcc: | $(GCC_SRCDIR)
	ln -sf $(GCC_SRCDIR) $@

src_musl: | $(MUSL_SRCDIR)
	ln -sf $(MUSL_SRCDIR) $@

ifneq ($(GMP_SRCDIR),)
src_toolchain: src_gmp
src_gmp: | $(GMP_SRCDIR)
	ln -sf "$(GMP_SRCDIR)" $@
endif

ifneq ($(MPC_SRCDIR),)
src_toolchain: src_mpc
src_mpc: | $(MPC_SRCDIR)
	ln -sf "$(MPC_SRCDIR)" $@
endif

ifneq ($(MPFR_SRCDIR),)
src_toolchain: src_mpfr
src_mpfr: | $(MPFR_SRCDIR)
	ln -sf "$(MPFR_SRCDIR)" $@
endif

src_toolchain: src_binutils src_gcc
	rm -rf $@ $@.tmp
	mkdir $@.tmp
	cd $@.tmp && ln -sf ../src_binutils/* .
	cd $@.tmp && ln -sf ../src_gcc/* .
	$(if $(GMP_SRCDIR),cd $@.tmp && ln -sf ../src_gmp gmp)
	$(if $(MPC_SRCDIR),cd $@.tmp && ln -sf ../src_mpc mpc)
	$(if $(MPFR_SRCDIR),cd $@.tmp && ln -sf ../src_mpfr mpfr)
	mv $@.tmp $@

obj_%:
	mkdir -p $@

obj_sysroot/include:
	mkdir -p $@

obj_sysroot/usr: | obj_sysroot
	ln -sf . $@

obj_sysroot/lib64: | obj_sysroot
	ln -sf lib $@

obj_toolchain/.lc_configured: | obj_toolchain src_toolchain
	cd obj_toolchain && ../src_toolchain/configure $(FULL_TOOLCHAIN_CONFIG)
	touch $@

obj_toolchain/gcc/.lc_built: | obj_toolchain/.lc_configured obj_sysroot/usr obj_sysroot/lib64 obj_sysroot/include
	cd obj_toolchain && $(MAKE) MAKE="$(MAKE)" LC_ROOT=$(PWD) all-gcc
	touch $@

obj_musl/.lc_configured: | obj_toolchain/gcc/.lc_built obj_musl src_musl
	cd obj_musl && ../src_musl/configure $(MUSL_CONFIG)
	touch $@

obj_sysroot/.lc_headers: | obj_musl/.lc_configured obj_sysroot
	cd obj_musl && $(MAKE) DESTDIR=$(PWD)/obj_sysroot install-headers
	touch $@

obj_toolchain/$(TARGET)/libgcc/.lc_configured: | obj_sysroot/.lc_headers
	cd obj_toolchain && $(MAKE) MAKE="$(MAKE)" LC_ROOT=$(PWD) configure-target-libgcc
	touch $@

obj_toolchain/$(TARGET)/libgcc/libgcc.a: | obj_toolchain/$(TARGET)/libgcc/.lc_configured
	cd $(dir $@) && $(MAKE) MAKE="$(MAKE)" LC_ROOT=$(PWD) libgcc.a

obj_musl/.lc_built: | obj_toolchain/$(TARGET)/libgcc/libgcc.a
	cd obj_musl && $(MAKE) $(MUSL_VARS)
	touch $@

obj_sysroot/.lc_libs: | obj_musl/.lc_built
	cd obj_musl && $(MAKE) $(MUSL_VARS) DESTDIR=$(PWD)/obj_sysroot install
	touch $@

obj_toolchain/.lc_built: | obj_toolchain/.lc_configured obj_sysroot/.lc_libs
	cd obj_toolchain && $(MAKE) MAKE="$(MAKE)" LC_ROOT=$(PWD)
	touch $@

install-musl: | obj_musl/.lc_built
	cd obj_musl && $(MAKE) $(MUSL_VARS) DESTDIR=$(DESTDIR)$(OUTPUT)/$(TARGET) install

install-toolchain: | obj_toolchain/.lc_built
	cd obj_toolchain && $(MAKE) MAKE="$(MAKE)" LC_ROOT=$(PWD) DESTDIR=$(DESTDIR)$(OUTPUT) install

endif

clean:
	rm -rf src_* obj_*
