# Get system type
# NOTICE: Must use "=" instead of ":=", or $(findstr) will not work.
UNAME	= $(shell uname -a)

#
##################### Build dependencies #####################
#

ARCH_PACMAN_DEPS	:= git ruby ruby-rake tar zip wget cmake bison autoconf automake libtool patch pkgconf \
	fftw mxml liblo zlib libx11 mesa
APT_DEPS			:= git ruby ruby-dev bison autotools-dev automake libtool premake4 cmake wget pkgconf \
	                   gcc g++ libfftw3-dev libmxml-dev liblo-dev zlib1g-dev libx11-dev mesa-common-dev libuv1-dev
MSYS2_PACMAN_DEPS	:= git ruby gcc bison util-macros automake libtool mingw-w64-x86_64-cmake cmake \
					mingw-w64-x86_64-mruby python3 autoconf zip make wget patch \
					mingw-w64-x86_64-gcc mingw-w64-x86_64-make mingw-w64-x86_64-pkgconf \
					mingw-w64-x86_64-gcc-fortran mingw-w64-x86_64-gcc-libgfortran \
					mingw-w64-x86_64-fltk mingw-w64-x86_64-fftw

DNF_DEPS := git ruby rubygem-rake ruby-devel bison autoconf automake libtool premake cmake wget pkgconf \
	    gcc g++ fftw-devel mxml-devel liblo-devel zlib-devel libX11-devel mesa-libGL-devel mesa-libGLU-devel libuv-devel

APK_DEPS := gcc g++ wget zlib-dev fftw-dev libuv-static libuv-dev ruby ruby-rake libx11-dev mesa-dev bison cmake liblo-dev mxml-dev

install_deps:
# Only allow being invoked within Makefile.<TARGET>.mk
ifeq (, $(filter Makefile.%.mk,$(MAKEFILE_LIST)))
	$(info ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━)
	$(info Some dependencies are target-specific, which is unnecessary to other targets.) 
	$(info Please invoke install_deps in Makefile.*.mk instead:)
	$(info )
	$(info [        make -f Makefile.<TARGET>.mk install_deps        ])
	$(info ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━)
	$(error )
endif

# Check for system versions
ifneq (, $(findstring Linux,$(UNAME)))

ifneq (, $(wildcard /usr/bin/apt))
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "  Detected Host OS: Debian/Ubuntu with APT                     "
	@echo "  Installing dependencies via APT...                           "
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	sudo apt -y update
	sudo apt -y install $(APT_DEPS)

else ifneq (, $(wildcard /usr/bin/pacman))
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "  Detected Host OS: Arch Linux or directive                    "
	@echo "  Installing dependencies via Pacman...                        "
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	sudo pacman -Syyu
	sudo pacman -S $(ARCH_PACMAN_DEPS) --noconfirm

else ifneq (, $(wildcard /sbin/apk))
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "  Detected Host OS: Alpine Linux or directive                  "
	@echo "  Installing dependencies via apk...                           "
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	apk add $(APK_DEPS)

else ifneq (, $(wildcard /bin/dnf))
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "  Detected Host OS: Fedora Linux or directive                  "
	@echo "  Installing dependencies via dnf...                           "
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	sudo dnf -y install $(DNF_DEPS)

else
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  Cannot install dependencies for your Linux distribution automatically.         "
	@echo "                                                                                 "
	@echo "  Please refer to $(lastword $(MAKEFILE_LIST)) to get a list of package names,   "
	@echo "  then manually install them via your package manager.                           "
	@echo "                                                                                 "
	@echo "  Patches are always welcomed!                                                   "
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@false
endif

else ifneq (, $(findstring Msys,$(UNAME)))
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "  Detected Host environment: Msys2                             "
	@echo "  Installing dependencies via Pacman...                        "
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	pacman -Syyu
	pacman -S $(MSYS2_PACMAN_DEPS)

else ifneq (, $(findstring CYGWIN,$(UNAME)))
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  Sorry. Cannot install dependencies for Cygwin,                           "
	@echo "  since it has no package manager CLI.                                     "
	@echo "                                                                           "
	@echo "  Please refer to $(lastword $(MAKEFILE_LIST)) to fetch what you need      "
	@echo "  via Cygwin setup.                                                        "
	@echo "                                                                           "
	@echo "  Msys2 is highly recommended.                                             "
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@false

else
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "   Your OS may not be supported.                                         "
	@echo "   You have to install dependencies by yourself.                         "
	@echo "                                                                         "
	@echo "   See $(lastword $(MAKEFILE_LIST)) to get a list of package names.      "
	@echo "                                                                         "
	@echo "   Patches are always welcomed!                                          "
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@false
endif


#
##################### Dependencies for Windows build #####################
#

# Download/extract ZynAddSubFX's dependency sources

# FFTW's GitHub repo is not out-of-box (ready for compiling right now).
# The authors recommend that we fetch tarball instead.
$(DEPS_PATH)/fftw: prepare_workspace
ifeq (, $(wildcard $(DOWNLOAD_PATH)/fftw*.tar.gz))
	# File doesn't exist. Must redownload.
	wget http://www.fftw.org/fftw-3.3.4.tar.gz -O $(DOWNLOAD_PATH)/fftw-3.3.4.tar.gz
endif
	mkdir -p $@
	$(TAR_UNPACK)  $(DOWNLOAD_PATH)/fftw*tar.gz -C $@ --skip-old-files

$(DEPS_PATH)/liblo: prepare_workspace
ifeq (, $(wildcard $(DOWNLOAD_PATH)/liblo*.tar.gz))
	wget http://downloads.sourceforge.net/liblo/liblo-0.28.tar.gz -O $(DOWNLOAD_PATH)/liblo-0.28.tar.gz
endif
	mkdir -p $@
	$(TAR_UNPACK)  $(DOWNLOAD_PATH)/liblo*tar.gz -C $@ --skip-old-files

$(DEPS_PATH)/mxml: prepare_workspace
ifeq (, $(wildcard $(DOWNLOAD_PATH)/mxml*.tar.gz))
	wget https://github.com/michaelrsweet/mxml/releases/download/release-2.10/mxml-2.10.tar.gz -O $(DOWNLOAD_PATH)/mxml-2.10.tar.gz
endif
	mkdir -p $@
	$(TAR_UNPACK)  $(DOWNLOAD_PATH)/mxml*tar.gz -C $@ --skip-old-files

$(DEPS_PATH)/portaudio: prepare_workspace
ifeq (, $(wildcard $(DOWNLOAD_PATH)/pa_*.tgz))
	wget http://www.portaudio.com/archives/pa_stable_v19_20140130.tgz -O $(DOWNLOAD_PATH)/pa_stable_v19_20140130.tgz
endif
	mkdir -p $@
	$(TAR_UNPACK)  $(DOWNLOAD_PATH)/pa_stable*.tgz -C $@ --skip-old-files 

$(DEPS_PATH)/zlib: prepare_workspace
ifeq (, $(wildcard $(DOWNLOAD_PATH)/zlib*.tar.gz))
	wget http://downloads.sourceforge.net/libpng/zlib/1.2.7/zlib-1.2.7.tar.gz -O $(DOWNLOAD_PATH)/zlib-1.2.7.tar.gz
endif
	mkdir -p $@
	$(TAR_UNPACK)  $(DOWNLOAD_PATH)/zlib*.tar.gz -C $@ --skip-old-files 


# Download/extract libuv, Zest's dependency.
# I fetch libuv separately due to my network issue.
#
# Invoking `make setup` or `make setupwin` within mruby-zest-build/ 
# will also download/extract libuv,
# but it still downloads even though already downloaded.

UV_DIR    = libuv-v1.9.1
UV_FILE   = $(UV_DIR).tar.gz
UV_URL    = http://dist.libuv.org/dist/v1.9.1/$(UV_FILE)

setup_libuv: fetch_zest
ifeq (, $(wildcard $(DOWNLOAD_PATH)/$(UV_FILE)))
	wget $(UV_URL) -O $(DOWNLOAD_PATH)/$(UV_FILE)
endif
	rm -rf $(ZEST_PATH)/deps/$(UV_DIR)
	tar -xf $(DOWNLOAD_PATH)/$(UV_FILE) -C $(ZEST_PATH)/deps/


#
##################### Possible polyfills (workarounds) #####################
#

##### Original mruby-zest uses iij's mruby-process, which only supports Unix-based systems.
##### So I may need to replace it with appPlant's MinGW-compatible edition.
#####
##### But @fundamental proves that mruby-process is actually not a dependency for Zest,
##### and needed to bypass it in [mruby-zest-build/build_config.rb]:
#####    > Comment this line:
#####          conf.gem 'deps/mruby-process'
##### appPlant's version will also cause linker errors.
#####
##### Eventually, no need to do this polyfill. Just keep it as a backup.
####
####MRUBY_PROCESS_PATH	:= $(ZEST_PATH)/deps/mruby-process 
####MRUBY_PROCESS_REMOTE_URL	:= $(shell cd $(MRUBY_PROCESS_PATH); git remote get-url origin)
####
####mruby_process_polyfill: 
####ifeq (, $(findstring appPlant/mruby-process,$(MRUBY_PROCESS_REMOTE_URL)))
####	@echo "Polyfill: Replacing mruby-process with appPlant's MinGW-compatible edition..."
####	@echo
####	rm -rf $(MRUBY_PROCESS_PATH)
####	git clone https://github.com/appPlant/mruby-process $(MRUBY_PROCESS_PATH) 
####else
####	@echo No need to polyfill mruby-process. Updating...
####	@echo
####	cd $(MRUBY_PROCESS_PATH); \
####	git fetch; \
####	git checkout -f master
####endif
