package: defaults-dev
version: v1
env:
  CXXFLAGS: "-fPIC -O2 -std=c++14 -march=native"
  CXX_STANDARD: "14"
  CFLAGS: "-fPIC -O2"
  CMAKE_BUILD_TYPE: "RELEASE"
disable:
  - AliEn-Runtime
  - MonALISA-gSOAP-client
  - AliEn-CAs
  - ApMon-CPP
overrides:
  autotools:
    tag: v1.5.0
  boost:
    version:  "%(tag_basename)s"
    tag: "v1.67.0"
    requires:
      - "GCC-Toolchain:(?!osx)"
      - Python
    prefer_system_check: |
     printf "#include \"boost/version.hpp\"\n# if (BOOST_VERSION != 106700)\n#error \"Cannot use system's boost. Boost > 1.64.00 required.\"\n#endif\nint main(){}" | gcc -I$(brew --prefix boost)/include -xc++ - -o /dev/null
  GCC-Toolchain:
    tag: v6.2.0-alice1
    prefer_system_check: |
      echo true
      # set -e
      # which gfortran || { echo "gfortran missing"; exit 1; }
      # which cc && test -f $(dirname $(which cc))/c++ && printf "#define GCCVER ((__GNUC__ << 16)+(__GNUC_MINOR__ << 8)+(__GNUC_PATCHLEVEL__))\n#if (GCCVER < 0x060000 || GCCVER > 0x090000)\n#error \"System's GCC cannot be used: we need GCC 6.X. We are going to compile our own version.\"\n#endif\n" | cc -xc++ - -c -o /dev/null
  XRootD:
    tag: v4.8.3
  FairMQ:
    tag: v1.2.7.1
  FairLogger:
    tag: v1.5.0
  ROOT:
    version: "%(tag_basename)s"
    tag: "v6-16-00"
    source: https://github.com/root-mirror/root
    requires:
      - GSL
      - opengl:(?!osx)
      - Xdevel:(?!osx)
      - FreeType:(?!osx)
      - Python-modules
      - zlib
      - libxml2
      - "OpenSSL:(?!osx)"
      - "osx-system-openssl:(osx.*)"
      - XRootD
      - pythia
      - pythia6
  GSL:
    version: "v1.16%(defaults_upper)s"
    source: https://github.com/alisw/gsl
    tag: "release-1-16"
    prefer_system_check: |
      printf "#include \"gsl/gsl_version.h\"\n#define GSL_V GSL_MAJOR_VERSION * 100 + GSL_MINOR_VERSION\n# if (GSL_V < 116)\n#error \"Cannot use system's gsl. Notice we only support versions from 1.16 (included)\"\n#endif\nint main(){}" | gcc  -I$(brew --prefix gsl)/include -xc++ - -o /dev/null
  FairRoot:
    tag: v18.2.0
    source: https://github.com/FairRootGroup/FairRoot
  log4cpp:
    version: "%(tag_basename)s"
    tag: REL_1_1_1_Nov_26_2013
    source: https://github.com/ShipSoft/log4cpp
  GEANT4:
    version: "%(tag_basename)s"
    tag: v10.3.2
    source: https://github.com/geant4/geant4.git
    requires:
      - "GCC-Toolchain:(?!osx)"
      - opengl
      - xercesc
    env:
      G4INSTALL: "$GEANT4_ROOT"
      G4SYSTEM: "$(uname)-g++"
      G4VERSION: "Geant4-10.3.2"
      G4INSTALL_DATA: "$GEANT4_ROOT/share/$G4VERSION/data"
      G4ABLADATA:               "$GEANT4_ROOT/share/$G4VERSION/data/G4ABLA3.0"
      G4LEDATA:                 "$GEANT4_ROOT/share/$G4VERSION/data/G4EMLOW6.50"
      G4ENSDFSTATEDATA:         "$GEANT4_ROOT/share/$G4VERSION/data/G4ENSDFSTATE2.1"
      G4NeutronHPCrossSections: "$GEANT4_ROOT/share/$G4VERSION/data/G4NDL4.5"
      G4NEUTRONHPDATA:          "$GEANT4_ROOT/share/$G4VERSION/data/G4NDL4.5"
      G4NEUTRONXSDATA:          "$GEANT4_ROOT/share/$G4VERSION/data/G4NEUTRONXS1.4"
      G4PIIDATA:                "$GEANT4_ROOT/share/$G4VERSION/data/G4PII1.3"
      G4SAIDXSDATA:             "$GEANT4_ROOT/share/$G4VERSION/data/G4SAIDDATA1.1"
      G4LEVELGAMMADATA:         "$GEANT4_ROOT/share/$G4VERSION/data/PhotonEvaporation4.3.2"
      G4RADIOACTIVEDATA:        "$GEANT4_ROOT/share/$G4VERSION/data/RadioactiveDecay5.1.1"
      G4REALSURFACEDATA:        "$GEANT4_ROOT/share/$G4VERSION/data/RealSurface1.0"
  GEANT4_VMC:
    version: "%(tag_basename)s"
    tag: v3-6-ship
    source: https://github.com/ShipSoft/geant4_vmc.git
  GENIE:
    tag: v2.12.6-ship
  pythia:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/pythia8
    tag: v8230-ship
    requires:
      - lhapdf5
      - HepMC
      - boost
  vgm:
    version: "%(tag_basename)s"
    tag: "4.4"
  evtGen:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/evtgen
    tag: R01-06-00-ship
  PHOTOSPP:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/PHOTOSPP
    tag: v3.61
  Tauolapp:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/Tauolapp
    tag: v1.1.5-ship
  pythia6:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/pythia6
    tag: v6.4.28-ship1
  GEANT3:
    version: "%(tag_basename)s"
    source: https://github.com/ShipSoft/geant3
    tag: v3.2.1-ship-patch-TVMC
---
