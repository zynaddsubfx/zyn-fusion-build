#Settings
CurrentVersion = "3.0.2"

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
    cmd   "git clone --depth=1 git@fundamental-code.com:mruby-zest-build"
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
    cmd   "cmake ../zynaddsubfx/ -DGuiModule=zest -DDemoMode=#{demo_mode} -DCMAKE_INSTALL_PREFIX=/usr"
    cmd   "make"
    chdir ".."
end

def build_zest(demo_mode=true)
    mode = demo_mode ? "demo" : "release"
    stage "Building Zest in #{mode} mode"
    chdir "mruby-zest-build"
    cmd   "make clean"
    ENV["VERSION"]    = CurrentVersion
    ENV["BUILD_MODE"] = mode
    cmd   "rm -f package/qml/*.qml"
    cmd   "ruby rebuild-fcache.rb"
    #cmd   "mv testing-cache.rb src/mruby-widget-lib/mrblib/fcache.rb"
    cmd   "make"
    cmd   "make pack"
    cmd   "rm package/qml/*.qml"
    chdir ".."
end

def make_package_from_repos(demo_mode=true)
    mode = demo_mode ? "demo" : "release"
    stage "Making a package in #{mode} mode"
    chdir "build-zynaddsubfx-#{mode}"
    cmd   "sudo make install"
    chdir ".."
    chdir "mruby-zest-build"
    cmd   "pwd"
    #ENV["ZYN_FUSION_VERSION"] = CurrentVersion
    cmd   "sudo ./linux-pack.sh linux-64bit-#{CurrentVersion}-#{mode}"
    chdir ".."
    cmd   "sudo mv /opt/zyn-fusion-linux-64bit-#{CurrentVersion}-#{mode}.tar.bz2 ./"
    cmd   "sudo chown mark zyn-fusion-linux-64bit-#{CurrentVersion}-#{mode}.tar.bz2"
end

def build_demo_package()
    mode = "demo"
    stage "Building a package in #{mode} mode"
    build_zynaddsubfx(true)
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

clean()

get_zynaddsubfx()
get_zest()

build_demo_package()
build_release_package()

display_reminders()
