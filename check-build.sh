#!/bin/bash -e
# check build script for velvet.

. /etc/profile.d/modules.sh

module load ci
module add zlib
cd ${WORKSPACE}/${NAME}_${VERSION}/
make test
echo $?


mkdir -p ${REPO_DIR}
mkdir -p ${SOFT_DIR}/bin
cp velvetg velveth velvetg_de velveth_de ${SOFT_DIR}/bin
# we need to add velvet's code and built files to ${SOFT_DIR} so that oases can use them later
ls obj
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
setenv       VELVET_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH                 $::env(VELVET_DIR)/bin
MODULE_FILE
) > modules/$VERSION

mkdir -p ${BIOINFORMATICS_MODULES}/${NAME}
cp modules/$VERSION ${BIOINFORMATICS_MODULES}/${NAME}
