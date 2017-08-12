#Settings
CurrentVersion = "3.0.2-patch4"

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
    cmd "rm -f fftw-*.tar.gz*"
    cmd "rm -f liblo-*.tar.gz*"
    cmd "rm -f mxml-*.tar.gz*"
    cmd "rm -f zlib-*.tar.gz*"
    cmd "rm -f pa_stable_*.tgz*"
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
    cmd   "mkdir -p pkg"
    cmd   "sh ./z/build-fftw.sh"
    #cmd   "sh ./z/build-jack.sh"
    cmd   "sh ./z/build-liblo.sh"
    cmd   "sh ./z/build-mxml.sh"
    cmd   "sh ./z/build-portaudio.sh"
    cmd   "sh ./z/build-zlib.sh"
    cmd   "cp ./libwinpthread* ./pkg/bin/"
end

def get_zest()
    stage "Getting Zest"
    #Clone the unreleased UI submodules
    cmd   "git clone --depth=1 git@fundamental-code.com:mruby-zest-build"
    chdir "mruby-zest-build"
    cmd   "git submodule update --init"

    #Apply patches which have been at least mentioned upstream
    chdir "deps/mruby-dir-glob"
    cmd   "git apply ../../../mruby-dir-glob-no-process.patch"
    chdir "../mruby-io"
    cmd   "git apply ../../../mruby-io-libname.patch"
    chdir "../../mruby"
    cmd   "git apply ../../mruby-float-patch.patch"
    chdir "../"

    cmd   "ruby rebuild-fcache.rb"
    cmd   "make setupwin"
    cmd   "make builddepwin"
    chdir ".."
end

def build_zynaddsubfx(demo_mode=true)
    mode = demo_mode ? "demo" : "release"
    stage "Building ZynAddSubFX in #{mode} mode"
    cmd   "mkdir -p build-zynaddsubfx-#{mode}"
    chdir "build-zynaddsubfx-#{mode}"
    cmd   "cmake ../zynaddsubfx/ -DCMAKE_TOOLCHAIN_FILE=../z/windows-build.cmake -DGuiModule=zest -DDemoMode=#{demo_mode} -DCMAKE_INSTALL_PREFIX=/usr"
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
    ENV["AR"]       = "/usr/bin/x86_64-w64-mingw32-ar"
    ENV["LD"]       = "/usr/bin/x86_64-w64-mingw32-gcc"
    ENV["CCLD"]     = "/usr/bin/x86_64-w64-mingw32-gcc"
    ENV["CFLAGS"]   = '-g -I/usr/share/mingw-w64/include/ -I/usr/x86_64-w64-mingw32/include/'

    cmd   "rm -f package/qml/*.qml"
    cmd   "ruby rebuild-fcache.rb"
    cmd   "make windows"
    #cmd   "make pack"
    #cmd   "rm package/qml/*.qml"
    chdir ".."
end

def make_package_from_repos(demo_mode=true)
    mode = demo_mode ? "demo" : "release"
    stage "Making a package in #{mode} mode"
    #chdir "build-zynaddsubfx-#{mode}"
    #cmd   "sudo make install"
    cmd   "pwd"
    #ENV["ZYN_FUSION_VERSION"] = CurrentVersion
    #cmd   "sudo ./linux-pack.sh linux-64bit-#{CurrentVersion}-#{mode}"
    cmd "rm    -rf w64-package"
    cmd "mkdir -p w64-package"
    cmd "mkdir -p w64-package/qml"
    cmd "touch    w64-package/qml/MainWindow.qml"
    cmd "mkdir -p w64-package/font"
    cmd "mkdir -p w64-package/schema"
    cmd "cp    mruby-zest-build/zest.exe         w64-package/zyn-fusion.exe"
    cmd "cp    mruby-zest-build/libzest.dll      w64-package/libzest.dll"
    cmd "cp    `find mruby-zest-build/deps/nanovg -type f | grep ttf$`                      w64-package/font/"
    cmd "cp    mruby-zest-build/src/osc-bridge/schema/test.json  w64-package/schema/"
    cmd "cp    build-zynaddsubfx-#{mode}/src/Plugin/ZynAddSubFX/ZynAddSubFX.dll w64-package/"
    cmd "cp    build-zynaddsubfx-#{mode}/src/zynaddsubfx.exe                       w64-package/"
    cmd "cp    pkg/bin/libportaudio-2.dll                    w64-package/"
    cmd "cp    pkg/bin/libwinpthread-1.dll                   w64-package/"
    cmd "cp -a zynaddsubfx/instruments/banks                 w64-package/"

    cmd "echo `date` > w64-package/VERSION"

    cmd "echo `pwd`"

    cmd "rm -f w64-package/qml/LocalPropTest.qml"
    cmd "rm -f w64-package/qml/FilterView.qml"
    name = "zyn-fusion-windows-64bit-#{CurrentVersion}-#{mode}"
    cmd "rm -rf #{name}"
    cmd "rm -f  #{name}.zip"
    cmd "mv w64-package #{name}"
    cmd "zip -q -r #{name}.zip #{name}/*"
    #chdir ".."
    #cmd   "sudo mv /opt/zyn-fusion-linux-64bit-#{CurrentVersion}-#{mode}.tar.bz2 ./"
    #cmd   "sudo chown mark zyn-fusion-linux-64bit-#{CurrentVersion}-#{mode}.tar.bz2"
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

apt_deps = %w{git ruby ruby-dev bison g++-mingw-w64-x86-64 autotools-dev automake libtool premake4 cmake}

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
