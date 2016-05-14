
OUTPUT = $(PWD)/output

BINUTILS_SRCDIR = BINUTILS_SRCDIR_not_set
GCC_SRCDIR = GCC_SRCDIR_not_set
MUSL_SRCDIR = MUSL_SRCDIR_not_set

COMMON_CONFIG = --enable-languages=c,c++
GCC_CONFIG = $(COMMON_CONFIG) 
TOOLCHAIN_CONFIG = $(GCC_CONFIG)

XGCC_DIR = ../obj_toolchain/gcc
XGCC = $(XGCC_DIR)/xgcc -B $(XGCC_DIR)

-include config.mak

MAKE += MULTILIB_OSDIRNAMES=
MAKE += INFO_DEPS= infodir=
MAKE += ac_cv_prog_lex_root=lex.yy.c

FULL_TOOLCHAIN_CONFIG = $(TOOLCHAIN_CONFIG) \
	--disable-werror \
	--target=$(TARGET) --prefix= \
	--libdir=/lib --disable-multilib \
	--with-sysroot=$(SYSROOT) \
	--with-build-sysroot='$$(LC_ROOT)/obj_sysroot' \
	--enable-tls \
	--disable-libmudflap --disable-libsanitizer \
	--disable-gnu-indirect-function \
	--disable-libmpx \
	--enable-libstdcxx-time

FULL_MUSL_CONFIG = $(MUSL_CONFIG) \
	--prefix= --host=$(TARGET)

ifeq ($(NATIVE),)
SYSROOT = /$(TARGET)
FULL_MUSL_CONFIG += CC="$(XGCC)" LIBCC="../obj_toolchain/$(TARGET)/libgcc/libgcc.a" 
MUSL_VARS = AR=../obj_toolchain/binutils/ar RANLIB=../obj_toolchain/binutils/ranlib
obj_musl/.lc_built: | obj_toolchain/$(TARGET)/libgcc/libgcc.a
obj_toolchain/.lc_built: | obj_sysroot/.lc_libs
else
SYSROOT = /
FULL_TOOLCHAIN_CONFIG += --host=$(TARGET)
MUSL_VARS = 
endif

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
	cd obj_musl && ../src_musl/configure $(FULL_MUSL_CONFIG)
	touch $@

obj_sysroot/.lc_headers: | obj_musl/.lc_configured obj_sysroot
	cd obj_musl && $(MAKE) DESTDIR=$(PWD)/obj_sysroot install-headers
	touch $@

obj_toolchain/$(TARGET)/libgcc/.lc_configured: | obj_sysroot/.lc_headers
	cd obj_toolchain && $(MAKE) MAKE="$(MAKE)" LC_ROOT=$(PWD) configure-target-libgcc
	touch $@

obj_toolchain/$(TARGET)/libgcc/libgcc.a: | obj_toolchain/$(TARGET)/libgcc/.lc_configured
	cd $(dir $@) && $(MAKE) MAKE="$(MAKE)" LC_ROOT=$(PWD) libgcc.a

obj_musl/.lc_built: | obj_musl/.lc_configured
	cd obj_musl && $(MAKE) $(MUSL_VARS)
	touch $@

obj_sysroot/.lc_libs: | obj_musl/.lc_built
	cd obj_musl && $(MAKE) $(MUSL_VARS) DESTDIR=$(PWD)/obj_sysroot install
	touch $@

obj_toolchain/.lc_built: | obj_toolchain/.lc_configured obj_sysroot/.lc_headers
	cd obj_toolchain && $(MAKE) MAKE="$(MAKE)" LC_ROOT=$(PWD)
	touch $@

install-musl: | obj_musl/.lc_built
	cd obj_musl && $(MAKE) $(MUSL_VARS) DESTDIR=$(DESTDIR)$(OUTPUT)$(SYSROOT) install

install-toolchain: | obj_toolchain/.lc_built
	cd obj_toolchain && $(MAKE) MAKE="$(MAKE)" LC_ROOT=$(PWD) DESTDIR=$(DESTDIR)$(OUTPUT) install
	ln -sf $(TARGET)-gcc $(DESTDIR)$(OUTPUT)/bin/$(TARGET)-cc

ifneq ($(LINUX_SRCDIR),)
TARGET_ARCH = $(firstword $(subst -, ,$(TARGET)))
TARGET_ARCH_MANGLED = $(patsubst i%86,x86,$(patsubst aarch64%,arm64%,$(TARGET_ARCH)))
LINUX_ARCH_LIST = $(sort $(notdir $(wildcard $(LINUX_SRCDIR)/arch/*)))
LINUX_ARCH = $(firstword $(foreach a,$(LINUX_ARCH_LIST),$(findstring $(a),$(TARGET_ARCH_MANGLED))))
ifneq ($(LINUX_ARCH),)
all: kernel-headers
install: install-kernel-headers
kernel-headers: | obj_kernel_headers
src_kernel_headers: | $(LINUX_SRCDIR)
	rm -rf $@.tmp $@
	mkdir -p $@.tmp/arch/$(LINUX_ARCH)
	cp -R $(LINUX_SRCDIR)/arch/$(LINUX_ARCH)/include $@.tmp/arch/$(LINUX_ARCH)
	cp -R $(LINUX_SRCDIR)/arch/$(LINUX_ARCH)/Makefile $@.tmp/arch/$(LINUX_ARCH)
	cp -R $(LINUX_SRCDIR)/include $@.tmp
	cp -R $(LINUX_SRCDIR)/scripts $@.tmp
	cp -R $(LINUX_SRCDIR)/Makefile $@.tmp
	mv $@.tmp $@
obj_kernel_headers: | src_kernel_headers
	rm -rf $@.tmp $@
	cd src_kernel_headers && $(MAKE) ARCH=$(LINUX_ARCH) INSTALL_HDR_PATH=$(PWD)/$@.tmp headers_install
	mv $@.tmp $@
install-kernel-headers: | obj_kernel_headers
	mkdir -p $(DESTDIR)$(OUTPUT)$(SYSROOT)/include
	cp -R obj_kernel_headers/include/* $(DESTDIR)$(OUTPUT)$(SYSROOT)/include
endif
endif

endif

clean:
	rm -rf src_* obj_*
