include Common.mk
include Install-deps.mk

OS		:= linux

#
############################ ZynAddSubFX Rules ############################
#

#
# Final make rule
#
get_zynaddsubfx: fetch_zynaddsubfx

build_zynaddsubfx:
	$(info ========== Building ZynAddSubFX in $(MODE) mode ==========)

	rm -rf $(ZYNADDSUBFX_BUILD_DIR)
	mkdir -p $(ZYNADDSUBFX_BUILD_DIR)

	cd $(ZYNADDSUBFX_BUILD_DIR); \
	cmake $(ZYNADDSUBFX_PATH) \
		-DGuiModule=zest \
		-DDemoMode=$(DEMO_MODE) \
		-DCMAKE_INSTALL_PREFIX=/usr \

	$(MAKE) -C $(ZYNADDSUBFX_BUILD_DIR)

#
############################ Zest Rules ############################
#

revoke_mruby_patches: fetch_zest
ifneq ($(ZEST_COMMIT), DIRTY)
	cd $(ZEST_PATH)/mruby ; \
	git checkout -- .
endif

setup_zest: fetch_zest revoke_mruby_patches
	cd $(ZEST_PATH) ; \
	ruby rebuild-fcache.rb

#
# Final Make rule
#
get_zest: fetch_zest revoke_mruby_patches setup_zest

build_zest:
	$(info ========== Building Zest in $(MODE) mode ==========)

	$(MAKE) -C $(ZEST_PATH) clean

	cd $(ZEST_PATH); \
	rm -f package/qml/*.qml; \
	ruby rebuild-fcache.rb

	VERSION=$(VER) BUILD_MODE=$(MODE) \
	$(MAKE) -C $(ZEST_PATH)
	$(MAKE) -C $(ZEST_PATH) pack

	cd $(ZEST_PATH); \
	rm -f package/qml/*.qml

#
############################ Packing Up Rules ############################
#

TARGET_TAR_FILE	:= $(BUILD_PATH)/zyn-fusion-linux-64bit-$(VER)-$(MODE).tar.bz2
ZYN_FUSION_OUT	:= $(BUILD_PATH)/zyn-fusion-linux-64bit-$(VER)-$(MODE)

preinstall_zynaddsubfx:
	rm -rf $(ZYNADDSUBFX_INSTALL_DIR)
	$(MAKE) DESTDIR="$(ZYNADDSUBFX_INSTALL_DIR)" -C $(ZYNADDSUBFX_BUILD_DIR) install

copy_zest_files: preinstall_zynaddsubfx
	rm -rf $(ZYN_FUSION_OUT)
	mkdir  $(ZYN_FUSION_OUT)
	
	cp   -a $(ZYNADDSUBFX_INSTALL_DIR)/usr/lib/lv2/ZynAddSubFX.lv2presets	 $(ZYN_FUSION_OUT)/
	
	cp   -a $(ZYNADDSUBFX_PATH)/instruments/banks		 $(ZYN_FUSION_OUT)/
	cp	  $(ZEST_PATH)/package/libzest.so   $(ZYN_FUSION_OUT)/
	cp	  $(ZEST_PATH)/package/zest		 $(ZYN_FUSION_OUT)/zyn-fusion
	cp   -a $(ZEST_PATH)/package/font		 $(ZYN_FUSION_OUT)/
	
	mkdir  $(ZYN_FUSION_OUT)/qml
	touch  $(ZYN_FUSION_OUT)/qml/MainWindow.qml
	
	cp   -a $(ZEST_PATH)/package/schema	   $(ZYN_FUSION_OUT)/
	cp	 -r $(ZYNADDSUBFX_INSTALL_DIR)/usr/lib/lv2/ZynAddSubFX.lv2 $(ZYN_FUSION_OUT)/ZynAddSubFX.lv2/
	cp	 -r $(ZYNADDSUBFX_INSTALL_DIR)/usr/lib/vst3/ZynAddSubFX.vst3 $(ZYN_FUSION_OUT)/ZynAddSubFX.vst3/
	cp	  $(ZYNADDSUBFX_INSTALL_DIR)/usr/lib/vst/ZynAddSubFX-vst2.so $(ZYN_FUSION_OUT)/
	cp	  $(ZYNADDSUBFX_INSTALL_DIR)/usr/lib/clap/ZynAddSubFX.clap $(ZYN_FUSION_OUT)/

	cp	  $(ZYNADDSUBFX_BUILD_DIR)/src/zynaddsubfx $(ZYN_FUSION_OUT)/
	cp	  $(ZEST_PATH)/install-linux.sh $(ZYN_FUSION_OUT)/
	cp	  $(ZEST_PATH)/package-README.txt $(ZYN_FUSION_OUT)/README.txt
	cp	  $(ZYNADDSUBFX_PATH)/COPYING $(ZYN_FUSION_OUT)/COPYING.zynaddsubfx

package: preinstall_zynaddsubfx copy_zest_files
	rm -rf $(TARGET_TAR_FILE)
	
# Use `basename` to avoid packing up absolute path
	cd $(ZYN_FUSION_OUT)/../ ; \
	tar acf $(TARGET_TAR_FILE) ./$(shell basename $(ZYN_FUSION_OUT))
	ls
	@echo "Finished! Made Package in $(MODE) Mode"
