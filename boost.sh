package: boost
version: "%(tag_basename)s%(defaults_upper)s"
source: https://github.com/FairRootGroup/boost.git
tag: "v1.67.0"
requires:
 - Python
build_requires:
 - "bz2"
prefer_system: (?!slc5)
prefer_system_check: |
  printf "#include \"boost/version.hpp\"\n# if (BOOST_VERSION < 106400 || BOOST_VERSION > 106499)\n#error \"Cannot use system's boost: boost 1.64 required.\"\n#endif\nint main(){}" | gcc -I$(brew --prefix boost)/include -xc++ - -o /dev/null
---
#!/bin/bash -e


TMPB2=$BUILDDIR/tmp-boost-build

if [ -z "$CXX_COMPILER" ]; then
  case $ARCHITECTURE in
    osx*)
      TOOLSET=clang
      ;;
    *)
      TOOLSET=gcc
      ;;
  esac
else
  # In case the compiler is defined with the full path add the path to the PATH environment variable
  # Otherwise boost may pickup the wrong compiler
  DIR=${CXX_COMPILER%/*}
  [[ -z "$DIR" ]] || export PATH=$DIR:$PATH
  case $CXX_COMPILER in
    *icpc*)
      case $ARCHITECTURE in
        osx*)
          TOOLSET=intel-darwin
          ;;
        *)
          TOOLSET=intel-linux
          ;;
      esac
      ;;
    *clang++*)
      TOOLSET=clang
      ;;
    *g++*)
      case $ARCHITECTURE in
        osx*)
          TOOLSET=darwin
          ;;
        *)
          TOOLSET=gcc
          ;;
      esac
      ;;
    *)
      echo "Compiler is not supported"
      exit 1
      ;;
  esac
fi

if [[ $CXXFLAGS == *"-std=c++11"* ]]; then
  EXTRA_CXXFLAGS="cxxflags=\"-std=c++11\""
  if [[ $CXXFLAGS == *"-stdlib=libc++"* ]]; then
    EXTRA_CXXFLAGS="cxxflags=\"-std=c++11\" cxxflags=\"-stdlib=libc++\" linkflags=\"-stdlib=libc++\""
  fi
elif [[ $CXXFLAGS == *"-std=c++14"* ]]; then
  EXTRA_CXXFLAGS="cxxflags=\"-std=c++14\""
  if [[ $CXXFLAGS == *"-stdlib=libc++"* ]]; then
    EXTRA_CXXFLAGS="cxxflags=\"-std=c++14\" cxxflags=\"-stdlib=libc++\" linkflags=\"-stdlib=libc++\""
  fi
else
  EXTRA_CXXFLAGS=""
fi

rsync -a $SOURCEDIR/ $BUILDDIR/
cd $BUILDDIR/tools/build
bash bootstrap.sh --with-toolset=$TOOLSET
mkdir -p $TMPB2
./b2 install --prefix=$TMPB2
export PATH=$TMPB2/bin:$PATH
cd $BUILDDIR
b2 -q                        \
   -d2                       \
   ${JOBS+-j $JOBS}          \
   --prefix=$INSTALLROOT     \
   --build-dir=build-boost   \
   --disable-icu             \
   --without-container       \
   --without-context         \
   --without-coroutine       \
   --without-graph           \
   --without-graph_parallel  \
   --without-locale          \
   --without-math            \
   --without-mpi             \
   --without-wave            \
   --debug-configuration     \
   toolset=$TOOLSET          \
   link=shared               \
   threading=multi           \
   variant=release           \
   $EXTRA_CXXFLAGS           \
   install
[[ $BOOST_PYTHON ]] && ls -1 "$INSTALLROOT"/lib/*boost_python* > /dev/null

if [[ ${ARCHITECTURE:0:3} == "osx" ]]; then
  /usr/bin/find "$INSTALLROOT"/lib/libboost* -type f | \
  while read BIN; do
    MACHOTYPE=$(set +o pipefail; otool -h "$BIN" 2> /dev/null | grep filetype -A1 | tail -n1 | awk '{print $5}')
    # See mach-o/loader.h from XNU sources: 2 == executable, 6 == dylib
    if [[ $MACHOTYPE == 6 ]]; then
      install_name_tool -add_rpath "$INSTALLROOT/lib/" "$BIN"
    fi
  done
fi



# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0 ${GCC_TOOLCHAIN_VERSION:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION} ${PYTHON_VERSION:+Python/$PYTHON_VERSION-$PYTHON_REVISION}
# Our environment
setenv BOOST_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(BOOST_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(BOOST_ROOT)/lib")
EoF
