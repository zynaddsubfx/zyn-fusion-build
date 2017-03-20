#Settings
CurrentVersion = "3.1.2-rc3"

def cmd(x)
    puts x
    puts `#{x}`
end

def stage(x)
    puts "# #{x}"
end

def chdir(x)
    puts "Changing directory to #{x}"
end

def clean()
    cmd "rm -rf zynaddsubfx"
    cmd "rm -rf mruby-zest-build"
end

def get_zynaddsubfx()
    stage "Getting ZynAddSubFX"
    cmd   "git clone https://github.com/zynaddsubfx/zynaddsubfx"
end

def get_zest()
    stage "Getting Zest"
    cmd   "git clone git@fundamental-code.com:mruby-zest-build"
end

def build_zynaddsubfx(demo_mode=true)
    mode = demo_mode?"demo":"release"
    stage "Building ZynAddSubFX in #{mode} mode"
    cmd   "mkdir build-zynaddsubfx"
    chdir "build-zynaddsubfx-#{mode}"
    cmd   "cmake ../zynaddsubfx/ -DGuiModule=zest -DDemoMode=#{demo_mode}"
    cmd   "make"
    chdir ".."
end

def build_zest(demo_mode=true)
    mode = demo_mode?"demo":"release"
    stage "Building Zest in #{mode} mode"
    chdir "mruby-zest-build"
    cmd   "make clean"
    cmd   "ruby rebuild-fcache.rb"
    cmd   "mv testing-cache.rb src/mruby-widget-lib/mrblib/fcache.rb"
    cmd   "BUILD_MODE=#{mode}; make"
    cmd   "make pack"
    chdir ".."
end

def make_package_from_repos(demo_mode=true)
    mode = demo_mode?"demo":"release"
    stage "Making a package in #{mode} mode"
    chdir "build-zynaddsubfx-#{mode}"
    cmd   "sudo make install"
    chdir ".."
    chdir "mruby-zest-build"
    cmd   "sudo linux-pack.sh"
    chdir ".."
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
