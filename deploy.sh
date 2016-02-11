#!/bin/bash -e
. /etc/profile.d/modules.sh

module add deploy
module add zlib
cd ${WORKSPACE}/${NAME}_${VERSION}/
make clean
make
make colordebug

mkdir -p ${REPO_DIR}
echo "making ${SOFT_DIR}"
mkdir -p ${SOFT_DIR}/bin

cp -v velvetg velveth velvetg_de velveth_de ${SOFT_DIR}/bin
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
setenv       VELVET_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH                 $::env(VELVET_DIR)/bin
MODULE_FILE
) > modules/$VERSION

mkdir -p ${BIOINFORMATICS_MODULES}/${NAME}
cp modules/$VERSION ${BIOINFORMATICS_MODULES}/${NAME}
