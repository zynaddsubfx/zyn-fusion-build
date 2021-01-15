VER	:= 3.0.5
# Mode can be set to either "demo" or "release"
# TODO: Use two final targets instead of manually setting this flag when invoking `make`
MODE	:= release
ifeq ($(MODE), demo)
DEMO_MODE	:= true
else
DEMO_MODE	:= false
endif

# Work directories
TOP			:= $(PWD)
WORKPATH	:= $(PWD)/tmp/
BUILD_PATH	:= $(PWD)/build/
DOWNLOAD_PATH	:= $(WORKPATH)/download
NORMAL_SRC_PATH	:= $(WORKPATH)/src
GIT_SRC_PATH	:= $(WORKPATH)/src_git
PREFIX_PATH		:= $(WORKPATH)/prefix

# Repositories
# You can replace them with your own fork.
ZYNADDSUBFX_REPO_URL	:= https://github.com/zynaddsubfx/zynaddsubfx
ZEST_REPO_URL		:= https://github.com/mruby-zest/mruby-zest-build

# Zyn's source pathes
ZYNADDSUBFX_PATH	:= $(GIT_SRC_PATH)/zynaddsubfx
ZEST_PATH	:= $(GIT_SRC_PATH)/mruby-zest-build

# Packaging directories
ZYNADDSUBFX_INSTALL_DIR := $(BUILD_PATH)/zynfx_install
ZYN_FUSION_OUT	:= $(BUILD_PATH)/zyn-fusion

TAR_UNPACK		:= tar -x --strip-components 1 -f

all: zynaddsubfx zest package

zynaddsubfx: get_zynaddsubfx build_zynaddsubfx
.PHONY: zynaddsubfx

zest: get_zest build_zest
.PHONY: zest


help:
	@echo -e \
	"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"\
	"                      Build Targets                      \n"\
	"\n"\
	"Usage: make [VARIABLE=VALUE] -f Makefile.<platform>.mk TARGETS \n"\
	"\n"\
	"Main targets: \n"\
	"  all            Build all targets (DEFAULT) \n"\
	"  zynaddsubfx    Build ZynAddSubFX core \n"\
	"  zest           Build Zyn-Fusion (Zest) UI \n"\
	"  package        Pack up built files after a successful compile \n"\
	" \n"\
	"  install_deps   Install build dependencies for known platforms \n"\
	"  clean          Clean build files without cleaning fetched sources \n"\
	"  distclean      Clean build files + fetched sources \n"\
	"  help           This help message \n"\
	" \n"\
	"Sub targets: \n"\
	"  get_zynaddsubfx       Fetch ZynAddSubFX and its dependencies, \n"\
	"                          then build those dependencies first \n"\
	"  get_zest              Fetch Zest, then prepare it for building \n"\
	"  build_zynaddsubfx     Start building ZynAddSubFX \n"\
	"  build_zest            Start building Zest \n"\
	"  copy_zest_files       Gather built program files \n"\
	"                          (which can directly run as you wish) \n"\
	" \n"\
	"Environment Variables: \n"\
	"  MODE=demo|release     Specify build type. (Default: release) \n"\
	"  ZYNADDSUBFX_REPO_URL  Specify another ZynAddSubFX repo URL\n"\
	"  ZEST_REPO_URL         Specify another Zest repo URL\n"\
	"                      ↑ You can use another Zyn forks as you wish.\n"\
	" \n"\
	"NOTICE: To debug, refer to source code for possible targets. \n"\
	"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

prepare_workspace: 
	mkdir -p $(WORKPATH) $(DOWNLOAD_PATH) $(NORMAL_SRC_PATH) $(GIT_SRC_PATH) $(PREFIX_PATH)

clean:
	rm -rf $(NORMAL_SRC_PATH)
	rm -rf $(PREFIX_PATH)
	rm -rf $(BUILD_PATH)

	$(MAKE) -C $(ZEST_PATH) clean
	rm -rf $(ZEST_PATH)/libzest* zest*

distclean: clean
	rm -rf $(WORKPATH)
