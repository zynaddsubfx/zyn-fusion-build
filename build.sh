#sudo apt install git -y
#sudo apt install ruby -y
#sudo apt install ruby-dev -y
#sudo apt install bison -y
#sudo apt install g++-mingw-w64-x86-64 -y
#sudo apt install autotools-dev -y
#sudo apt install automake -y
#sudo apt install libtool -y
#sudo apt install premake4 -y
#sudo apt install cmake

#git clone git@fundamental-code.com:mruby-zest-build

#rm    -rf build-dir
#mkdir     build-dir

echo '[INFO] change into the build dir'
cd        mruby-zest-build
#git submodule update --init

#git clone https://github.com/mruby/mruby

echo '[INFO] create build file'
cat > w64.rb <<EOL
MRuby::Build.new('host') do |conf|
  toolchain :gcc

  conf.cc do |cc|
    cc.command = 'gcc'
    cc.flags = []
  end
  conf.linker do |linker|
    linker.command = 'gcc'
    linker.flags   = []
  end
  conf.archiver do |archiver|
    archiver.command = 'ar'
  end
  conf.gembox 'default'
end

MRuby::CrossBuild.new('w64') do |conf|
  # load specific toolchain settings
  toolchain :gcc
  enable_debug
  conf.gembox 'default'
end
EOL

#cd mruby

#export MRUBY_CONFIG='../w64.rb'

#make clean
#make > ~/build-log.txt 2>&1
#make setupwin
#make builddepwin

export CC=/usr/bin/x86_64-w64-mingw32-gcc
export CXX=/usr/bin/x86_64-w64-mingw32-g++
export AR=/usr/bin/x86_64-w64-mingw32-ar 
export LD=/usr/bin/x86_64-w64-mingw32-gcc
export CCLD=/usr/bin/x86_64-w64-mingw32-gcc
#
export CFLAGS='-g -I/usr/share/mingw-w64/include/ -I/usr/x86_64-w64-mingw32/include/'

echo '[INFO] run build process'
rm -r mruby-zest-build/mruby/build/w64
make windows

cd ..
rm    -r w64-package
mkdir -p w64-package
mkdir -p w64-package/qml
touch    w64-package/qml/MainWindow.qml
mkdir -p w64-package/font
mkdir -p w64-package/schema
cp    mruby-zest-build/zest.exe         w64-package/zyn-fusion.exe
cp    mruby-zest-build/libzest.dll      w64-package/libzest.dll
cp    `find . -type f | grep ttf$`                      w64-package/font/
cp    mruby-zest-build/src/osc-bridge/schema/test.json  w64-package/schema/
cp    ~/z/zynaddsubfx/build/src/Plugin/ZynAddSubFX/ZynAddSubFX.dll w64-package/
cp    ~/z/zynaddsubfx/build/src/zynaddsubfx.exe                       w64-package/
cp    ~/z/pkg/bin/libportaudio-2.dll                    w64-package/
cp    ~/z/pkg/bin/libwinpthread-1.dll                   w64-package/
cp -a ~/z/zynaddsubfx/instruments/banks                 w64-package/

echo `date` > w64-package/VERSION

echo `pwd`

rm w64-package/qml/LocalPropTest.qml
rm w64-package/qml/FilterView.qml
rm -rf zyn-fusion-3.0.2
mv w64-package zyn-fusion-3.0.2
zip -q -r zyn-fusion-3.0.2rc1.zip zyn-fusion-3.0.2/*
#cat ~/build-log.txt
