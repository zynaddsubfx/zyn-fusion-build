include Common.mk
include Install-deps.mk

OS		:= windows

# Cross-compile dependencies
ARCH_PACMAN_DEPS	+= mingw-w64-toolchain
APT_DEPS			+= g++-mingw-w64-x86-64

# Cross-compile specific compilers
HOST	:= x86_64-w64-mingw32
CC		:= x86_64-w64-mingw32-gcc
CXX		:= x86_64-w64-mingw32-g++
AR		:= x86_64-w64-mingw32-ar
LD		:= x86_64-w64-mingw32-gcc
CCLD	:= x86_64-w64-mingw32-gcc

# Only Debian's MinGW-w64 has /usr/share/mingw-w64
ifneq (, $(wildcard /usr/share/mingw-w64))
ZEST_CFLAGS_MINGW	:= -g -I/usr/share/mingw-w64/include/ -I/usr/x86_64-w64-mingw32/include/
else
ZEST_CFLAGS_MINGW	:= -g -I/usr/x86_64-w64-mingw32/include/
endif


#
############################ ZynAddSubFX Rules ############################
#

#
# Fetch dependencies
#
# Downloading rules are in Install-deps.mk
#

copy_libwinpthread: prepare_workspace
	mkdir -p $(PREFIX_PATH)/bin/

# Arch Linux's MinGW-w64 puts libwinpthread-1.dll into "bin" instead of "lib"
ifneq (, $(wildcard /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll))
	cp /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll $(PREFIX_PATH)/bin/
else
	cp /usr/x86_64-w64-mingw32/bin/libwinpthread-1.dll $(PREFIX_PATH)/bin/
endif


#
# Build dependencies
#
build_fftw: $(DEPS_PATH)/fftw
	cd $< ; \
	./configure --host=$(HOST) --prefix=$(PREFIX_PATH) --with-our-malloc --disable-mpi

	$(MAKE) -C $<
	$(MAKE) -C $< install

build_liblo: $(DEPS_PATH)/liblo
	cd $< ; \
	./configure --host=$(HOST) --prefix=$(PREFIX_PATH) --disable-shared --enable-static

	$(MAKE) -C $<
	$(MAKE) -C $< install

build_mxml: $(DEPS_PATH)/mxml
	cd $< ; \
	./configure --host=$(HOST) --prefix=$(PREFIX_PATH) --disable-shared --enable-static

	$(MAKE) -C $< libmxml.a
	$(MAKE) -C $< -i install TARGETS=""

build_portaudio: $(DEPS_PATH)/portaudio
	cd $< ; \
	./configure --host=$(HOST) --prefix=$(PREFIX_PATH)

	$(MAKE) -C $<
	$(MAKE) -C $< install

build_zlib: $(DEPS_PATH)/zlib
	cd $< ; \
	CC=$(CC) ./configure --prefix=$(PREFIX_PATH) --static

	$(MAKE) -C $<
	$(MAKE) -C $< install

#
# Final make rule
#
build_zynaddsubfx_deps: build_fftw build_liblo build_mxml build_portaudio build_zlib copy_libwinpthread

get_zynaddsubfx: fetch_zynaddsubfx build_zynaddsubfx_deps

build_zynaddsubfx:
	$(info ========== Building ZynAddSubFX in $(MODE) mode ==========)

	rm -rf $(ZYNADDSUBFX_BUILD_DIR)
	mkdir -p $(ZYNADDSUBFX_BUILD_DIR)

	cd $(ZYNADDSUBFX_BUILD_DIR); \
	cmake $(ZYNADDSUBFX_PATH) \
		-DPREFIX_PATH=$(PREFIX_PATH) \
		-DCMAKE_FIND_ROOT_PATH=$(PREFIX_PATH) \
		-DCMAKE_TOOLCHAIN_FILE=$(TOP)/z/windows-build.cmake \
		-DGuiModule=zest \
		-DDemoMode=$(DEMO_MODE) \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DDefaultOutput=pa

	$(MAKE) -C $(ZYNADDSUBFX_BUILD_DIR)

#
############################ Zest Rules ############################
#


apply_mruby_patches: fetch_zest
ifneq ($(ZEST_COMMIT), DIRTY)
	cd $(ZEST_PATH)/mruby ; \
	git checkout -- . ; \
	patch -p1 -N < ../string-backtraces.diff
endif

#
# Final Make rule
#
get_zest: fetch_zest apply_mruby_patches

build_zest:
	$(info ========== Building Zest in $(MODE) mode ==========)

	$(MAKE) -C $(ZEST_PATH) clean

	cd $(ZEST_PATH); \
	rm -f package/qml/*.qml; \
	ruby rebuild-fcache.rb

	cd $(ZEST_PATH)/deps/mruby-file-stat/src; \
	../configure --host=$(HOST)

	env \
	VERSION=$(VER) BUILD_MODE=$(MODE) \
	CC=$(CC) CXX=$(CXX) AR=$(AR) LD=$(LD) CCLD=$(CCLD) \
	CFLAGS="$(ZEST_CFLAGS_MINGW)" \
	$(MAKE) -C $(ZEST_PATH) windows


#
############################ Packing Up Rules ############################
#

TARGET_ZIP_FILE	:= $(BUILD_PATH)/zyn-fusion-windows-64bit-$(VER)-$(MODE).zip
ZYN_FUSION_OUT	:= $(BUILD_PATH)/zyn-fusion-windows-64bit-$(VER)-$(MODE)

copy_zest_files:
	rm -rf $(ZYN_FUSION_OUT)
	mkdir -p $(ZYN_FUSION_OUT)

	mkdir -p $(ZYN_FUSION_OUT)/qml
	touch $(ZYN_FUSION_OUT)/qml/MainWindow.qml

	mkdir -p $(ZYN_FUSION_OUT)/font
	mkdir -p $(ZYN_FUSION_OUT)/schema

	cp $(ZEST_PATH)/zest.exe $(ZYN_FUSION_OUT)/zyn-fusion.exe
	cp $(ZEST_PATH)/libzest.dll $(ZYN_FUSION_OUT)/libzest.dll
	cp $(shell find $(ZEST_PATH)/deps/nanovg -type f | grep ttf$$) $(ZYN_FUSION_OUT)/font/
	cp $(ZEST_PATH)/src/osc-bridge/schema/test.json $(ZYN_FUSION_OUT)/schema/

	cp $(ZYNADDSUBFX_BUILD_DIR)/src/Plugin/ZynAddSubFX/ZynAddSubFX.dll $(ZYN_FUSION_OUT)/
	cp $(ZYNADDSUBFX_BUILD_DIR)/src/zynaddsubfx.exe $(ZYN_FUSION_OUT)/

	cp $(PREFIX_PATH)/bin/libportaudio-2.dll $(ZYN_FUSION_OUT)/
	cp $(PREFIX_PATH)/bin/libwinpthread-1.dll $(ZYN_FUSION_OUT)/

	cp -a $(ZYNADDSUBFX_PATH)/instruments/banks $(ZYN_FUSION_OUT)/

	echo `date` > $(ZYN_FUSION_OUT)/VERSION


package: copy_zest_files
	rm -f $(ZYN_FUSION_OUT)/qml/LocalPropTest.qml
	rm -f $(ZYN_FUSION_OUT)/qml/FilterView.qml
	rm -f -r $(TARGET_ZIP_FILE)

	cd $(ZYN_FUSION_OUT)/../ ; \
	zip -q -r $(TARGET_ZIP_FILE) ./$(shell basename $(ZYN_FUSION_OUT))/*
	@echo "Finished! Made Package in $(MODE) Mode"
