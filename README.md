# Zyn-Fusion Build Scripts

These are the build scripts used to generate the Zyn-Fusion packages.

These build scripts (and only these build scripts) are licensed under the
WTFPL.

---

## Fetch repositories

You need to fetch this repo first (if you're using Windows, see below for how to do it).

```shell
git clone https://github.com/zynaddsubfx/zyn-fusion-build zyn-fusion-build
```
```shell
cd zyn-fusion-build
```

## How to build

Zyn-Fusion now uses Makefile. Each platform has a corresponding Makefile (`Makefile.<platform>.mk`):

| Makefile              | Target platform (Where Zyn runs) | Host platform (where compilers run) |
| --------------------- | -------------------------------- | ----------------------------------- |
| `Makefile.linux.mk`   | Linux (native build)             | Linux                               |
| `Makefile.windows.mk` | Windows                          | Linux **(cross compile)**           |
| `Makefile.mingw64.mk` | Windows                          | Msys2 Mingw-w64 64 bit              |

Since they are not in the default Makefile name, you need to explicitly specify them via parameter`-f` when invoking `make`.

Makefiles will automatically download ZynAddSubFX and Zest, as well as their dependencies. Then, automatically build them altogether.

**Built packages are put in directory `./build/` :**

- `./build/zyn-fusion`: Ready-to-use Zyn-Fusion files. You can directly use them as you wish, or copy this folder into your DAW's search-path.
- `./build/zyn-fusion/zyn-fusion-*.{tar.gz|zip}`:  Compressed package(s) ready for distribution.

### Building for Linux (native build)

#### Generic

```bash
# Install build dependencies
make -f Makefile.linux.mk install_deps

# Start building
make -f Makefile.linux.mk all

# Or, you can also build a specific component,
# then finally use `package` to get a package file
make -f Makefile.linux.mk zynaddsubfx
make -f Makefile.linux.mk zest
make -f Makefile.linux.mk package
```

> **NOTICE:** You need to run `install-linux.sh` within the built folder to install Zyn-Fusion properly, or it won't run, moreover you'll only see a black window in your host.

### Building for Windows (cross-compile on Linux)

```bash
# Install build dependencies
make -f Makefile.windows.mk install_deps

# Start building
make -f Makefile.windows.mk all

# Or, you can also build a specific component,
# then finally use `package` to get a package file
make -f Makefile.windows.mk zynaddsubfx
make -f Makefile.windows.mk zest
make -f Makefile.windows.mk package
```

### Building for Windows (native build via Msys2)

#### Msys2 installation

You must install [Msys2](https://www.msys2.org/) first.
**Remember to always use the `Mingw64` terminal** (you can find it in Start Menu).
Any other terminal will not work.

Then finish updating the Msys installation by running in the
Mingw64 terminal: `pacman -Suy` (twice).
See https://www.msys2.org/docs/updating/ for details and https://archlinux.org/pacman/pacman.8.html for ̀pacman`.

#### Bootstrapping

Checking out the code:

```
pacman -S git make
git clone https://github.com/zynaddsubfx/zyn-fusion-build zyn-fusion-build
cd zyn-fusion-build
```

Then install the required tools through pacman:

```
make -f Makefile.mingw64.mk install_deps
```

#### Compile ZynFusion

To compile everything:

```
make -f Makefile.mingw64.mk all
```

Alternatively you can also build a specific component, then finally use `package` to get a package file:

```
make -f Makefile.mingw64.mk zynaddsubfx
make -f Makefile.mingw64.mk zest
make -f Makefile.mingw64.mk package
```

### Moreover

- **Build types (modes):** You can choose either `demo` or `release`, and `demo` is the default. Demo build will automatically mute after 10 minutes.

  You can explicitly specify build type:
  
  ```bash
  make MODE=release -f Makefile.<platform>.mk <target>
  ```
  
- **Get help:** You can get a list of `make` targets by invoking:

  ```bash
  make -f Makefile.<platform>.mk help
  ```
