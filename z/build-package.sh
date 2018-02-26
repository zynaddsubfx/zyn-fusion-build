
echo "-----------------Building a package in $1 Mode-------------------------------------"
echo "####------------------------Building ZynaddSubFX in $1 mode-----------------------"
rm -rf build-zynaddsubfx-$1
mkdir 	-p build-zynaddsubfx-$1
rm -f cxx*tar.gz
wget https://sourceforge.net/projects/cxxtest/files/cxxtest/4.4/cxxtest-4.4.tar.gz
tar --strip-components=1 --directory="./pkg" -zxvf cxx* --overwrite  
export PATH=`pwd`/pkg/:$PATH
echo "$PATH"
export VERSION="3.0.3-patch1"
export BUILD_MODE=$1
cd 				build-zynaddsubfx-$1
cmake 			../zynaddsubfx/ -DCMAKE_TOOLCHAIN_FILE=../z/mingw64-build.cmake -G "MSYS Makefiles" -DOssEnable=False -DGuiModule=zest -DDemoMode=$2 -DCMAKE_INSTALL_PREFIX=/usr -DDefaultOutput=pa
set -e
make
cd ..
echo "	-------------------------Building Zest in '$1' Mode -----------------------------"
cd mruby-zest-build
make clean
rm -f package/qml/*.qml
ruby rebuild-fcache.rb
make windows
cd ..
echo "####-------------------------Making a package in $1 mode-----------------------------"
pwd
rm 				-rf w64-package
mkdir			-p w64-package
mkdir 			-p w64-package/qml
touch  			w64-package/qml/MainWindow.qml
mkdir 			-p w64-package/font
mkdir 			-p w64-package/schema
cp    			mruby-zest-build/zest.exe         							 w64-package/zyn-fusion.exe
cp    			mruby-zest-build/libzest.dll    						  	 w64-package/libzest.dll
cp    			`find mruby-zest-build/deps/nanovg -type f | grep ttf$` 	 w64-package/font/
cp    			mruby-zest-build/src/osc-bridge/schema/test.json  			 w64-package/schema/
cp    			build-zynaddsubfx-$1/src/Plugin/ZynAddSubFX/ZynAddSubFX.dll  w64-package/
cp    			build-zynaddsubfx-$1/src/zynaddsubfx.exe                     w64-package/
cp    			pkg/bin/libportaudio-2.dll                  				 w64-package/
cp    			pkg/bin/libwinpthread-1.dll                   				 w64-package/
cp 				-a zynaddsubfx/instruments/banks                 			 w64-package/
echo 			`date` > w64-package/VERSION
rm 				-f w64-package/qml/LocalPropTest.qml
rm 				-f w64-package/qml/FilterView.qml
rm 				-f -r zyn-fusion-windows-64bit-$1.zip
rm 				-rf zyn-fusion-windows-64bit-$1
mv 				w64-package zyn-fusion-windows-64bit-$1
zip 			-q -r zyn-fusion-windows-64bit-$1.zip zyn-fusion-windows-64bit-$1/*
echo 			"Finished! Made Package in $1 Mode"
