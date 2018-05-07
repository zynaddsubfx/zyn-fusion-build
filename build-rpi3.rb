#Settings
CurrentVersion = "3.0.3-patch1-rpi3"

def cmd(x)
    puts x
    ret = system(x)
    if(!ret)
        puts "ERROR: '#{x}' failed"
        exit
    end
end

def stage(x)
    puts "# #{x}"
end

def chdir(x)
    puts "Changing directory to #{x}"
    Dir.chdir(x)
end

def clean()
    cmd "rm -rf zynaddsubfx"
    cmd "rm -rf mruby-zest-build"
    cmd "rm -rf build-zynaddsubfx*"
end

def get_zynaddsubfx()
    stage "Getting ZynAddSubFX"
    cmd   "git clone --depth=1 https://github.com/zynaddsubfx/zynaddsubfx"
    chdir "zynaddsubfx"
    cmd   "git submodule update --init"
    chdir ".."
end

def get_zest()
    stage "Getting Zest"
    #Clone the unreleased UI submodules
    cmd   "git clone --depth=1 https://github.com/mruby-zest/mruby-zest-build"
    chdir "mruby-zest-build"
    cmd   "git submodule update --init"
    cmd   "ruby rebuild-fcache.rb"
    #cmd   "mv testing-cache.rb src/mruby-widget-lib/mrblib/fcache.rb"
    cmd   "make setup"
    cmd   "make builddep"
    chdir ".."
end

def build_zynaddsubfx(demo_mode=true)
    mode = demo_mode ? "demo" : "release"
    stage "Building ZynAddSubFX in #{mode} mode"
    cmd   "mkdir -p build-zynaddsubfx-#{mode}"
    chdir "build-zynaddsubfx-#{mode}"
    cmd   "cmake ../zynaddsubfx/ -DGuiModule=zest -DDemoMode=#{demo_mode} -DCMAKE_INSTALL_PREFIX=/usr -DBuildOptions_NEON='-march=armv8-a+crc -mfloat-abi=hard -mfpu=neon-fp-armv8 -mtune=cortex-a53 -mvectorize-with-neon-quad -Ofast'"
    cmd   "make -j2"
    chdir ".."
end

def build_zest(demo_mode=true)
    mode = demo_mode ? "demo" : "release"
    stage "Building Zest in #{mode} mode"
    chdir "mruby-zest-build"
    cmd   "make clean"
    ENV["VERSION"]    = CurrentVersion
    ENV["BUILD_MODE"] = mode
    # change GL2 to GLES2
    cmd   "sed -i -- 's/GL2/GLES2/g' src/mruby-widget-lib/src/gem.c"
    cmd   "sed -i -- 's/MRUBY_NANOVG_GL2/MRUBY_NANOVG_GLES2/g' build_config.rb"
    cmd   "sed -i '/idiot/d' deps/mruby-nanovg/src/nvg_impl.h"
    cmd   "cp ../gl_core.3.2.* deps/mruby-nanovg/src"
    # end change GLES2
    # compiler flags for rpi3
    cmd   "sed -i 's/-fPIC/-fPIC -march=armv8-a+crc -mfloat-abi=hard -mfpu=neon-fp-armv8 -mtune=cortex-a53 -mvectorize-with-neon-quad -Ofast/g' build_config.rb"
    # end compiler flags
    cmd   "rm -f package/qml/*.qml"
    cmd   "ruby rebuild-fcache.rb"
    #cmd   "mv testing-cache.rb src/mruby-widget-lib/mrblib/fcache.rb"
    cmd   "make -j2"
    cmd   "make pack"
    cmd   "rm package/qml/*.qml"
    chdir ".."
end

def make_package_from_repos(demo_mode=true)
    mode = demo_mode ? "demo" : "release"
    zyn  = "./build-zynaddsubfx-#{mode}"
    this_dir = `pwd`.strip
    stage "Making a package in #{mode} mode"
    chdir "build-zynaddsubfx-#{mode}"
    cmd   "sudo make install"
    chdir ".."
    cmd "sudo rm -rf /opt/zyn-fusion"
    cmd "sudo mkdir /opt/zyn-fusion"
    cmd "sudo chown $(whoami):users /opt/zyn-fusion || true"
    cmd "echo 'Version #{CurrentVersion}' | sudo tee /opt/zyn-fusion/VERSION"
    cmd "echo 'Build on'                  | sudo tee /opt/zyn-fusion/VERSION"
    cmd "echo `date`                      | sudo tee /opt/zyn-fusion/VERSION"
    cmd "sudo cp   -a /usr/lib/lv2/ZynAddSubFX.lv2presets     /opt/zyn-fusion/"
    cmd "sudo cp   -a ./zynaddsubfx/instruments/banks         /opt/zyn-fusion/"
    cmd "unzip -o ZynAddSubFX_C_Owl_Alvarez_full_bank.zip"
    cmd "sudo mv Cris\\ Owl\\ Alvarez/ /opt/zyn-fusion/banks"
    cmd "sudo cp      ./mruby-zest-build/package/libzest.so   /opt/zyn-fusion/"
    cmd "sudo cp      ./mruby-zest-build/package/zest         /opt/zyn-fusion/zyn-fusion"
    cmd "sudo cp   -a ./mruby-zest-build/package/font         /opt/zyn-fusion/"
    cmd "sudo mkdir  /opt/zyn-fusion/qml"
    cmd "sudo touch  /opt/zyn-fusion/qml/MainWindow.qml"
    cmd "sudo cp   -a ./mruby-zest-build/package/schema       /opt/zyn-fusion/"
    cmd "sudo mkdir   /opt/zyn-fusion/ZynAddSubFX.lv2"
    cmd "sudo cp      #{zyn}/src/Plugin/ZynAddSubFX/lv2/* /opt/zyn-fusion/ZynAddSubFX.lv2/"
    cmd "sudo cp      #{zyn}/src/Plugin/ZynAddSubFX/vst/ZynAddSubFX.so /opt/zyn-fusion/"
    cmd "sudo cp      #{zyn}/src/zynaddsubfx /opt/zyn-fusion/"
    cmd "sudo cp      ./mruby-zest-build/install-linux.sh /opt/zyn-fusion/"
    cmd "sudo cp      ./mruby-zest-build/package-README.txt /opt/zyn-fusion/README.txt"
    cmd "sudo cp      ./zynaddsubfx/COPYING /opt/zyn-fusion/COPYING.zynaddsubfx"
    chdir "/opt/"
    cmd "sudo rm -f zyn-fusion-linux-#{CurrentVersion}-#{mode}.tar zyn-fusion-linux-#{CurrentVersion}-#{mode}.tar.bz2"
    cmd "sudo tar cf zyn-fusion-linux-#{CurrentVersion}-#{mode}.tar ./zyn-fusion"
    cmd "sudo bzip2 zyn-fusion-linux-#{CurrentVersion}-#{mode}.tar"
    chdir "#{this_dir}/"
    cmd   "sudo mv /opt/zyn-fusion-linux-#{CurrentVersion}-#{mode}.tar.bz2 ./"
    cmd   "sudo chown $(whoami) zyn-fusion-linux-#{CurrentVersion}-#{mode}.tar.bz2 || true"
end

def build_demo_package()
    mode = "demo"
    stage "Building a package in #{mode} mode"
    #build_zynaddsubfx(true)
    build_zest(true)
    make_package_from_repos(true)
end

def build_release_package()
    mode = "release"
    stage "Building a package in #{mode} mode"
    build_zynaddsubfx(false)
    build_zest(false)
    make_package_from_repos(false)
end

def display_reminders()
    puts "TODO put various reminders here for release process"
    puts "     (notes should be in zyn's docs)"
end

cmd "sudo echo sudo"

clean()

get_zynaddsubfx()
get_zest()

#build_demo_package()
build_release_package()

display_reminders()
