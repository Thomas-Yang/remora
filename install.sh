#!/bin/sh
# Installation script for REMORA
#
# Change CC, MPICC and the corresponding flags to match your own compiler in
# file "Makefile.in". You should not have to edit this file at all.
#
# v1.5 (2016-02-03)  Carlos Rosales-Fernandez
#                    Antonio Gomez-Iglesias
#
# Thanks to Kenneth Hoste, from HPC-UGent, for his input

# installation directory: use $REMORA_INSTALL_PREFIX if defined, current directory if not
export REMORA_DIR=${REMORA_INSTALL_PREFIX:-$PWD}
export PHI_BUILD=0

# Do not change anything below this line
#--------------------------------------------------------------------------------

mkdir -p $REMORA_DIR/bin
mkdir -p $REMORA_DIR/include
mkdir -p $REMORA_DIR/lib
mkdir -p $REMORA_DIR/share
mkdir -p $REMORA_DIR/python

REMORA_BUILD_DIR=$PWD

VERSION=1.5
COPYRIGHT1="Copyright 2016 The University of Texas at Austin."
COPYRIGHT2="License: MIT <http://opensource.org/licenses/MIT>"
COPYRIGHT3="This is free software: you are free to change and redistribute it."
COPYRIGHT4="There is NO WARRANTY of any kind"

BUILD_LOG="$REMORA_BUILD_DIR/remora_build.log"
INSTALL_LOG="$REMORA_BUILD_DIR/remora_install.log"

SEPARATOR="======================================================================"
PKG="Package  : REMORA"
VER="Version  : $VERSION"
DATE="Date     : `date +%Y.%m.%d`"
SYSTEM="System   : `uname -sr`"

# Record the local conditions for the compilation
echo
echo $SEPARATOR  | tee $BUILD_LOG
echo $PKG        | tee -a $BUILD_LOG
echo $VER        | tee -a $BUILD_LOG
echo $DATE       | tee -a $BUILD_LOG
echo $SYSTEM     | tee -a $BUILD_LOG
echo $SEPARATOR  | tee -a $BUILD_LOG
echo $COPYRIGHT1 | tee -a $BUILD_LOG
echo $COPYRIGHT2 | tee -a $BUILD_LOG
echo $COPYRIGHT3 | tee -a $BUILD_LOG
echo $COPYRIGHT4 | tee -a $BUILD_LOG
echo $SEPARATOR  | tee -a $BUILD_LOG
echo             | tee -a $BUILD_LOG

#Now build mpstat
echo "Building mpstat ..." | tee -a $BUILD_LOG
cd $REMORA_BUILD_DIR/extra
wget https://github.com/sysstat/sysstat/archive/v11.2.0.zip | tee -a $BUILD_LOG
unzip v11.2.0 | tee -a $BUILD_LOG
cd sysstat-11.2.0
./configure | tee -a $BUILD_LOG
make mpstat |  tee -a $BUILD_LOG
echo "Installing mpstat ..."
cp mpstat $REMORA_DIR/bin

if [ "$PHI_BUILD" == "1" ]; then
	echo "Building Xeon Phi affinity script ..."   |  tee -a $BUILD_LOG
	cd $REMORA_BUILD_DIR/extra/
	icc -mmic -o ma ./mic_affinity.c
	echo "Installing Xeon Phi affinity script ..." |  tee -a $INSTALL_LOG
	cp -v ./ma $REMORA_DIR/bin                     |  tee -a $INSTALL_LOG
fi

echo "Copying all scripts to installation folder ..." |  tee -a $INSTALL_LOG
cd $REMORA_BUILD_DIR
cp -vr ./src/* $REMORA_DIR/bin

echo "Installing python module blockdiag ..." | tee -a $INSTALL_LOG
module load python
pip install blockdiag --target=$REMORA_DIR/python

echo $SEPARATOR
echo "Installation of REMORA v$VERSION completed."
echo "For a fully functional installation make sure to:"; echo ""
echo "	export PATH=\$PATH:$REMORA_DIR/bin"
echo "	export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$REMORA_DIR/lib"
echo "	export PYTHONPATH=\$PYTHONPATH:$REMORA_DIR/python"
echo "	export REMORA_BIN=$REMORA_DIR/bin"; echo ""
echo "Good Luck!"
echo $SEPARATOR
