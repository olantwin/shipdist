package: G4PY
version: "%(tag_basename)s%(defaults_upper)s"
tag: v10.3.1
source: https://github.com/PMunkes/geant4
requires:
  - GEANT4
  - Python-modules
  - ROOT
  - boost
  - XercesC
  - opengl
build_requires:
  - CMake
  - "Xcode:(osx.*)"
env:
  G4PYINSTALL: "$G4PY_ROOT"
---
#!/bin/bash -e
cp -a $SOURCEDIR/environments/g4py/* $INSTALLROOT
cmake $INSTALLROOT                               \
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}     \
      -DBoost_NO_SYSTEM_PATHS=TRUE               \
      -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT" \
      -DBOOST_ROOT=${BOOST_ROOT}                 \
      -DXERCESC_ROOT_DIR=${XERCESC_ROOT}         \
      -DBoost_NO_BOOST_CMAKE=TRUE

make ${JOBS+-j $JOBS}
make ${JOBS+-j $JOBS} install



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
module load BASE/1.0 ROOT/$ROOT_VERSION-$ROOT_REVISION ${GEANT4_VERSION:+GEANT4/$GEANT4_VERSION-$GEANT4_REVISION} XercesC/$XERCESC_VERSION-$XERCESC_REVISION boost/$BOOST_VERSION-$BOOST_REVISION
# Our environment
setenv PYTHONPATH \$::env(BASEDIR)/lib:\$::env(BASEDIR)/lib/examples:\$::env(BASEDIR)/lib/tests
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(BASEDIR)/lib")
EoF
