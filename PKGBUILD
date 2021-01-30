# PKGBUILD for Zyn-Fusion build Makefiles
#
# NOTICE: This PKGBUILD is for building package with this repo's Makefiles only.
# You should first run `make -f Makefile.<platform>.mk all` to build ZynAddSubFX and Zest.
#
# If you want to build Zyn-Fusion with PKGBUILD from scratch,
# please use AUR instead: `yay -S zyn-fusion`
# 
# To be separated from AUR's version, generated package name will be "zyn-fusion-userbuild".
#
pkgname=zyn-fusion-userbuild
pkgver=3.0.6
pkgrel=4
pkgdesc="ZynAddSubFX with a new interactive UI. (User build edition)"
arch=('i686' 'x86_64')
url="http://zynaddsubfx.sourceforge.net/zyn-fusion.html"
license=('GPL2' 'LGPL2.1')
depends=('fftw' 'libglvnd' 'mxml' 'jack' 'liblo' 'alsa-lib' 'portaudio')
provides=('zynaddsubfx')
conflicts=('zynaddsubfx' 'zyn-fusion')

zyn_fusion_out_dir="$PWD"/build/zyn-fusion
zynaddsubfx_src_dir="$PWD"/tmp/src_git/zynaddsubfx

prepare() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━  ERROR  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  This PKGBUILD is for packing up Zyn-Fusion ONLY."
    echo "  It does not support building."
    echo ""
    echo "  You should invoke Makefile instead, by:"
    echo "        make -f Makefile.linux.mk zynaddsubfx"
    echo "        make -f Makefile.linux.mk zest"
    echo "        make -f Makefile.linux.mk packarch"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    false
}

package() {
    cd "$zyn_fusion_out_dir"
    
    echo "Installing Zyn-Fusion"
    install -d "$pkgdir"/opt/zyn-fusion/
    cp -r "$zyn_fusion_out_dir"/* "$pkgdir"/opt/zyn-fusion

    echo "Installing Symbolic Links"
    install -d "$pkgdir"/usr/bin/
    
    echo "...Zyn-Fusion"
    ln -s /opt/zyn-fusion/zyn-fusion  "$pkgdir"/usr/bin/

    echo "...ZynAddSubFX"
    ln -s /opt/zyn-fusion/zynaddsubfx "$pkgdir"/usr/bin/

    echo "...Banks"
    install -d "$pkgdir"/usr/share/zynaddsubfx/
    ln -s /opt/zyn-fusion/banks "$pkgdir"/usr/share/zynaddsubfx/banks

    echo "...vst version"
    install -d "$pkgdir"/usr/lib/vst
    ln -s /opt/zyn-fusion/ZynAddSubFX.so "$pkgdir"/usr/lib/vst/

    echo "...lv2 version"
    install -d "$pkgdir"/usr/lib/lv2/
    ln -s /opt/zyn-fusion/ZynAddSubFX.lv2        "$pkgdir"/usr/lib/lv2/
    ln -s /opt/zyn-fusion/ZynAddSubFX.lv2presets "$pkgdir"/usr/lib/lv2/

    echo "Installing Desktop Entries"
    install -d "$pkgdir"/usr/share/applications/
    install "$zynaddsubfx_src_dir"/*.desktop "$pkgdir"/usr/share/applications/
}
