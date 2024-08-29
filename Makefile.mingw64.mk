include Common.mk
include Install-deps.mk

OS		:= windows

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
	cp /mingw64/bin/libwinpthread* $(PREFIX_PATH)/bin/

#
# Build dependencies
#

build_fftw: $(DEPS_PATH)/fftw
	cd $< ; \
	./configure --prefix=$(PREFIX_PATH) --with-our-malloc --disable-mpi --enable-single

	$(MAKE) -C $<
	$(MAKE) -C $< install

build_libio: $(DEPS_PATH)/liblo
	cd $< ; \
	./configure --prefix=$(PREFIX_PATH) --disable-shared --enable-static

	$(MAKE) -C $<
	$(MAKE) -C $< install

build_mxml: $(DEPS_PATH)/mxml
	cd $< ; \
	./configure --prefix=$(PREFIX_PATH) --disable-shared --enable-static

	$(MAKE) -C $< libmxml.a
	$(MAKE) -C $< -i install TARGETS=""

build_portaudio: $(DEPS_PATH)/portaudio
	cd $< ; \
	./configure --prefix=$(PREFIX_PATH)

	$(MAKE) -C $<
	$(MAKE) -C $< install

build_zlib: $(DEPS_PATH)/zlib
	cd $< ; \
	cmake -G "MSYS Makefiles" -DCMAKE_INSTALL_PREFIX=$(PREFIX_PATH)

	$(MAKE) -C $<
	$(MAKE) -C $< install

#
# Final make rule
#
build_zynaddsubfx_deps: build_fftw build_libio build_mxml build_portaudio build_zlib copy_libwinpthread

get_zynaddsubfx: fetch_zynaddsubfx build_zynaddsubfx_deps

build_zynaddsubfx:
	$(info ========== Building ZynAddSubFX in $(MODE) mode ==========)

	rm -rf $(ZYNADDSUBFX_BUILD_DIR)
	mkdir -p $(ZYNADDSUBFX_BUILD_DIR)

	env \
	PATH=$(PREFIX_PATH):$(PATH) \
	VERSION=$(VER) \
	BUILD_MODE=$(MODE) \
	cmake -S $(ZYNADDSUBFX_PATH) -B $(ZYNADDSUBFX_BUILD_DIR) \
		-DCMAKE_TOOLCHAIN_FILE=$(TOP)/z/mingw64-build.cmake \
		-G "MSYS Makefiles" \
		-DOssEnable=False \
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


	#this patch is to fix a conflict between mingw and libuv.
	# the conflict is fixed in later versions of libuv, but mruby-zest uses an earlier version currently.
	cd $(ZEST_PATH)/deps/libuv ; \
	git checkout -- . ; \
	patch -p1 -N < $(TOP)/0001-build-fix-build-failures-with-MinGW-new-headers.patch
	
	
setup_zest: fetch_zest apply_mruby_patches setup_libuv
	cd $(ZEST_PATH) ; \
	ruby rebuild-fcache.rb


#
# Final Make rule
#
get_zest: fetch_zest apply_mruby_patches setup_zest

build_zest:
	$(info ========== Building Zest in $(MODE) mode ==========)

	$(MAKE) -C $(ZEST_PATH) clean

	cd $(ZEST_PATH); \
	rm -f package/qml/*.qml; \
	ruby rebuild-fcache.rb

	cd $(ZEST_PATH)/deps/mruby-file-stat/src; \
	../configure

	env \
	VERSION=$(VER) BUILD_MODE=$(MODE) \
	$(MAKE) \
	-C $(ZEST_PATH) windows


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

	cp	 -r $(ZYNADDSUBFX_BUILD_DIR)/bin/ZynAddSubFX.lv2 $(ZYN_FUSION_OUT)/ZynAddSubFX.lv2/
	cp	 -r $(ZYNADDSUBFX_BUILD_DIR)/bin/ZynAddSubFX.vst3 $(ZYN_FUSION_OUT)/ZynAddSubFX.vst3/
	cp	$(ZYNADDSUBFX_BUILD_DIR)/bin/ZynAddSubFX-vst2.dll $(ZYN_FUSION_OUT)/
	cp	$(ZYNADDSUBFX_BUILD_DIR)/bin/ZynAddSubFX.clap $(ZYN_FUSION_OUT)/
	cp	$(ZYNADDSUBFX_BUILD_DIR)/src/zynaddsubfx.exe $(ZYN_FUSION_OUT)/

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
