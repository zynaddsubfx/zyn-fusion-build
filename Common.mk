VER	:= 3.0.6-git
# Mode can be set to either "demo" or "release"
# TODO: Use two final targets instead of manually setting this flag when invoking `make`
MODE	:= demo
ifeq ($(MODE), demo)
DEMO_MODE	:= true
else
DEMO_MODE	:= false
endif

# Enable parallel build when invoking GNU Make
ifdef PARALLEL
MAKE	:= $(MAKE) -j`grep -c "processor" /proc/cpuinfo`
endif
#MAKE	:= $(MAKE) -j30

# Work directories
TOP			:= $(shell pwd)
WORKPATH	:= $(TOP)/tmp/
BUILD_PATH	:= $(TOP)/build/
DOWNLOAD_PATH	:= $(TOP)/download/
DEPS_PATH	:= $(TOP)/deps/
GIT_SRC_PATH	:= $(TOP)/src
PREFIX_PATH		:= $(WORKPATH)/prefix

# Repositories
# You can replace them with your own fork.
ZYNADDSUBFX_REPO_URL	:= https://github.com/zynaddsubfx/zynaddsubfx
ZEST_REPO_URL		:= https://github.com/mruby-zest/mruby-zest-build

ZYNADDSUBFX_COMMIT	:= origin/master
ZEST_COMMIT			:= origin/master

# Zyn's source pathes
ZYNADDSUBFX_PATH	:= $(GIT_SRC_PATH)/zynaddsubfx
ZEST_PATH	:= $(GIT_SRC_PATH)/mruby-zest-build

# Building & packaging directories
ZYNADDSUBFX_BUILD_DIR	= $(BUILD_PATH)/build-zynaddsubfx-$(OS)-$(MODE)
ZYNADDSUBFX_INSTALL_DIR = $(PREFIX_PATH)/zynfx_install

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
	"  ZYNADDSUBFX_COMMIT    Specify commit to checkout or DIRTY.\n"\
	"  ZEST_COMMIT           Specify commit to checkout or DIRTY.\n"\
	" \n"\
	"NOTICE: To debug, refer to source code for possible targets. \n"\
	"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

prepare_workspace:
	mkdir -p $(WORKPATH) $(DOWNLOAD_PATH) $(DEPS_PATH) $(GIT_SRC_PATH) $(PREFIX_PATH)

fetch_zynaddsubfx: prepare_workspace
	$(info ========== Fetching ZynAddSubFX ==========)
	$(info \n)
ifeq (, $(wildcard $(ZYNADDSUBFX_PATH)))
	$(info ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━)
	$(info WARNING!)
	$(info ZynAddSubFX is not fetched.)
	$(info Running `git clone` to get it.)
	$(info ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━)
	git clone $(ZYNADDSUBFX_REPO_URL) $(ZYNADDSUBFX_PATH)
endif
ifneq ($(ZYNADDSUBFX_COMMIT), DIRTY)
	cd $(ZYNADDSUBFX_PATH); \
	git fetch; \
	git checkout $(ZYNADDSUBFX_COMMIT); \
	git submodule update --init
else
	cd $(ZYNADDSUBFX_PATH); \
	git submodule update --init
endif

fetch_zest: prepare_workspace
	$(info ========== Fetching Zest ==========)
	$(info \n)
ifeq (,$(wildcard $(ZEST_PATH)))
	$(info ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━)
	$(info WARNING!)
	$(info Zest is not fetched.)
	$(info Running `git clone` to get it.)
	$(info ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━)
	git clone $(ZEST_REPO_URL) $(ZEST_PATH)
endif
ifneq ($(ZEST_COMMIT), DIRTY)
	cd $(ZEST_PATH); \
	git fetch; \
	git checkout $(ZEST_COMMIT); \
	git submodule update --init
else
	cd $(ZEST_PATH); \
	git submodule update --init
endif


# Clean built files, except those in dependencies' source path (as you can rebuild Zyn/Zest faster).
clean:
	rm -rf $(PREFIX_PATH)
	rm -rf $(BUILD_PATH)

	$(MAKE) -C $(ZEST_PATH) clean
	rm -rf $(ZEST_PATH)/libzest* zest*

# Clean all built files, including dependencies'.
distclean: clean
	rm -rf $(WORKPATH)

	for i in deps/fftw deps/liblo deps/mxml deps/portaudio deps/zlib; do \
	$(MAKE) -C $$i distclean; \
	done
