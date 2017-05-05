#!/bin/bash -e
# Copyright 2016 C.S.I.R. Meraka Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# check build script for velvet.

. /etc/profile.d/modules.sh

module add ci
module add zlib
module add  gcc/${GCC_VERSION}
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
setenv       VELVET_DIR                 /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH                       $::env(VELVET_DIR)/bin
MODULE_FILE
) > modules/$VERSION

mkdir -p ${BIOINFORMATICS}/${NAME}
cp modules/$VERSION ${BIOINFORMATICS}/${NAME}

module avail ${NAME}
module add ${NAME}/${VERSION}
which velvetg
