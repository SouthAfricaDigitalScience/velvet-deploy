#!/bin/bash -e
. /etc/profile.d/modules.sh

module add deploy
module add zlib
module add  gcc/${GCC_VERSION}
echo "making ${SOFT_DIR}"
mkdir -p ${SOFT_DIR}/bin

cd ${WORKSPACE}/${NAME}_${VERSION}/
make clean
make
cp -rvf obj ${SOFT_DIR}/
# unfortunately, the debug make actually cleans out objdir so we have to move the libs created in the default
# make before we run colour debug, then we have to move the stuff in colour debug
make colordebug
cp -rvf obj ${SOFT_DIR}/

echo "making ${SOFT_DIR}"
mkdir -p ${SOFT_DIR}

cp -v velvetg velveth velvetg_de velveth_de ${SOFT_DIR}/bin
# we need to add velvet's code and built files to ${SOFT_DIR} so that oases can use them later
cp -rvf obj ${SOFT_DIR}/
cp -rvf src ${SOFT_DIR}/
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       VELVET_VERSION       $VERSION
setenv       VELVET_DIR                 $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH                       $::env(VELVET_DIR)/bin
MODULE_FILE
) > modules/$VERSION

mkdir -p ${BIOINFORMATICS_MODULES}/${NAME}
cp -v modules/$VERSION ${BIOINFORMATICS_MODULES}/${NAME}

module  avail ${NAME}
module add ${NAME}/${VERSION}
module list
echo "checking for velvetg"
which velvetg
