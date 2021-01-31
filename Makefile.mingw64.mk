include Common.mk
include Install-deps.mk

OS		:= windows

#
############################ ZynAddSubFX Rules ############################
#

fetch_zynaddsubfx: prepare_workspace
	$(info ========== Getting ZynAddSubFX ==========)
	$(info \n)
ifeq (, $(wildcard $(ZYNADDSUBFX_PATH)))
	git clone --depth=1 $(ZYNADDSUBFX_REPO_URL) $(ZYNADDSUBFX_PATH)
endif
	cd $(ZYNADDSUBFX_PATH); \
	git submodule update --init

#
# Fetch dependencies
#
# Downloading rules are in Install-deps.mk
#

copy_libwinpthread: prepare_workspace
	cp /mingw64/bin/libwinpthread* $(PREFIX_PATH)/bin/

#
# Build dependencies
#
build_fftw: $(NORMAL_SRC_PATH)/fftw
	cd $< ; \
	./configure --prefix=$(PREFIX_PATH) --with-our-malloc --disable-mpi

	$(MAKE) -C $<
	$(MAKE) -C $< install

build_libio: $(NORMAL_SRC_PATH)/libio
	cd $< ; \
	./configure --prefix=$(PREFIX_PATH) --disable-shared --enable-static

	$(MAKE) -C $<
	$(MAKE) -C $< install

build_mxml: $(NORMAL_SRC_PATH)/mxml
	cd $< ; \
	./configure --prefix=$(PREFIX_PATH) --disable-shared --enable-static

	$(MAKE) -C $< libmxml.a
	$(MAKE) -C $< -i install TARGETS=""

build_portaudio: $(NORMAL_SRC_PATH)/portaudio
	cd $< ; \
	./configure --prefix=$(PREFIX_PATH)

	$(MAKE) -C $<
	$(MAKE) -C $< install

build_zlib: $(NORMAL_SRC_PATH)/zlib
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

fetch_zest: prepare_workspace
	$(info ========== Getting Zest ==========)
	$(info \n)
ifeq (,$(wildcard $(ZEST_PATH)))
	git clone --depth=1 $(ZEST_REPO_URL) $(ZEST_PATH)
endif
	cd $(ZEST_PATH); \
	git submodule update --init

apply_mruby_patches: fetch_zest
	cd $(ZEST_PATH)/deps/mruby-dir-glob ; \
	git checkout -- . ; \
	patch -N < $(TOP)/mruby-dir-glob-no-process.patch

	cd $(ZEST_PATH)/deps/mruby-io ; \
	git checkout -- . ; \
	patch -N < $(TOP)/mruby-io-libname.patch

	cd $(ZEST_PATH)/mruby ; \
	git checkout -- . ; \
	patch -p1 -N < $(TOP)/mruby-float-patch.patch

setup_zest: fetch_zest apply_mruby_patches setup_libuv
	cd $(ZEST_PATH) ; \
	ruby rebuild-fcache.rb

	$(MAKE) -C $(ZEST_PATH) --always-make builddepwin

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

TARGET_ZIP_FILE	:= $(BUILD_PATH)/zyn-fusion-windows-64bit-$(MODE).zip

copy_zest_files:
	rm -rf $(ZYN_FUSION_OUT)
	mkdir -p $(ZYN_FUSION_OUT)

	mkdir -p $(ZYN_FUSION_OUT)/qml
	touch $(ZYN_FUSION_OUT)/qml/MainWindow.qml

	mkdir -p $(ZYN_FUSION_OUT)/font
	mkdir -p $(ZYN_FUSION_OUT)/schema

	cp $(ZEST_PATH)/zest.exe $(ZYN_FUSION_OUT)/zyn-fusion.exe
	cp $(ZEST_PATH)/libzest.dll $(ZYN_FUSION_OUT)/libzest.dll
	cp $(shell find $(ZEST_PATH)/deps/nanovg -type f | grep ttf$) $(ZYN_FUSION_OUT)/font/
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
