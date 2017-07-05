def cmd(x)
    puts x
    ret = system(x)
    if(!ret)
        puts "ERROR: '#{x}' failed"
        exit
    end
end

def apt_install(lib)
    cmd "sudo apt install #{lib} -y"
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
    cmd   "mv testing-cache.rb src/mruby-widget-lib/mrblib/fcache.rb"
    cmd   "make setupwin"
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

    ENV["CC"]       = "/usr/bin/x86_64-w64-mingw32-gcc"
    ENV["CXX"]      = "/usr/bin/x86_64-w64-mingw32-g++"
    ENV["AR"]       = "/usr/bin/x86_64-w64-mingw32-ar "
    ENV["LD"]       = "/usr/bin/x86_64-w64-mingw32-gcc"
    ENV["CCLD"]     = "/usr/bin/x86_64-w64-mingw32-gcc"
    ENV["CFLAGS"]   = '-g -I/usr/share/mingw-w64/include/ -I/usr/x86_64-w64-mingw32/include/'

    cmd   "rm -f package/qml/*.qml"
    cmd   "ruby rebuild-fcache.rb"
    cmd   "mv testing-cache.rb src/mruby-widget-lib/mrblib/fcache.rb"
    cmd   "make windows"
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

apt_deps = %w{git ruby ruby-dev bison g++mingw-w64-x86_64 autotools-dev automake libtool premake4 cmake}

################################################################################
#                          Do The Build                                        #
################################################################################
apt_deps.each do |dep|
    apt_install dep
end

clean()

get_zynaddsubfx()
get_zest()

build_demo_package()
build_release_package()

display_reminders()

#echo '[INFO] create build file'
#cat > w64.rb <<EOL
#MRuby::Build.new('host') do |conf|
#  toolchain :gcc
#
#  conf.cc do |cc|
#    cc.command = 'gcc'
#    cc.flags = []
#  end
#  conf.linker do |linker|
#    linker.command = 'gcc'
#    linker.flags   = []
#  end
#  conf.archiver do |archiver|
#    archiver.command = 'ar'
#  end
#  conf.gembox 'default'
#end
#
#MRuby::CrossBuild.new('w64') do |conf|
#  # load specific toolchain settings
#  toolchain :gcc
#  enable_debug
#  conf.gembox 'default'
#end
#EOL

#cd mruby

#export MRUBY_CONFIG='../w64.rb'

#make clean
#make > ~/build-log.txt 2>&1
#make setupwin
#make builddepwin


#echo '[INFO] run build process'
#rm -r mruby-zest-build/mruby/build/w64
#make windows
#
#cd ..
#rm    -r w64-package
#mkdir -p w64-package
#mkdir -p w64-package/qml
#touch    w64-package/qml/MainWindow.qml
#mkdir -p w64-package/font
#mkdir -p w64-package/schema
#cp    mruby-zest-build/zest.exe         w64-package/zyn-fusion.exe
#cp    mruby-zest-build/libzest.dll      w64-package/libzest.dll
#cp    `find . -type f | grep ttf$`                      w64-package/font/
#cp    mruby-zest-build/src/osc-bridge/schema/test.json  w64-package/schema/
#cp    ~/z/zynaddsubfx/build/src/Plugin/ZynAddSubFX/ZynAddSubFX.dll w64-package/
#cp    ~/z/zynaddsubfx/build/src/zynaddsubfx.exe                       w64-package/
#cp    ~/z/pkg/bin/libportaudio-2.dll                    w64-package/
#cp    ~/z/pkg/bin/libwinpthread-1.dll                   w64-package/
#cp -a ~/z/zynaddsubfx/instruments/banks                 w64-package/
#
#echo `date` > w64-package/VERSION
#
#echo `pwd`
#
#rm w64-package/qml/LocalPropTest.qml
#rm w64-package/qml/FilterView.qml
#rm -rf zyn-fusion-3.0.2
#mv w64-package zyn-fusion-3.0.2
#zip -q -r zyn-fusion-3.0.2rc1.zip zyn-fusion-3.0.2/*
#cat ~/build-log.txt
