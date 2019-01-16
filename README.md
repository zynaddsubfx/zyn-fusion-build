These are the build scripts used to generate the Zyn-Fusion packages.

These build scripts (and only these build scripts) are licensed under the
WTFPL.

---

## Building on Windows 
0. download repository
1. install msys2 (https://www.msys2.org/) and run the msys2 shell
2. pacman -Sy
3. pacman -Syu
4. pacman -Su
5. pacman -S mingw-w64-x86_64-toolchain
6. install python 2.7 to local machine
7. copy files from python 2.7 to C:\msys64\mingw64\bin and rename python.exe to python2.exe (should look like C:\msys64\mingw64\bin\python2.exe
8. open c:\mingw64\mingw64.exe as administrator
9. run build-mingw64.sh from github download
10. manually add mruby-zest-build/deps/libuv.a and mruby-zest-build/deps/libuv-v1.9.1/.libs/libuv-win.a **while the script is running, as soon as the folders appear**

## Troubleshooting

-"Unknown command python2": Make sure you copied your python files correctly and renamed python.exe to python2.exe in the bin folder. If you did it correctly, "/bin/sh python2" should print "cannot execute binary file" instead of "no such file or directory"

-"Rake failed, libuv.a" or "libuv-win.a do not exist": Make sure you copied the files to the correct folder (zyn-fusion-build-master/mruby-zest-test/deps/libuv.a or zyn-fusion-build-master/mruby-zest-test/deps/libuv-v1.9.1/.libs/libuv-win.a)

-"Cannot rename file: reason, file exists": Disable your antivirus, especially the active scanning
