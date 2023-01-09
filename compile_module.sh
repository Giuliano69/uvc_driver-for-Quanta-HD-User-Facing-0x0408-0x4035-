#!/bin/bash
#this script is inspired to https://wiki.ubuntu.com/Kernel/Dev/KernelModuleRebuild

# $LINUX_SOURCE is used for the source tar file name, and the source directory names
LINUX_SOURCE=linux-source-5.15.0

#the specific module we wont to compile
MODULE_PATH=drivers/media/usb/uvc/

#define make remote directory  make O=...... to build the new module inside a different and specific "remote" directory tree
#WHEN using make with remote directory, according to https://www.linux.com/training-tutorials/kernel-newbie-corner-building-and-running-new-kernel/
#1 All of your make commands must be run from the top of the source tree, not the destination tree. 
#2 Once you start the remote configuration/build with the O= variable, all subsequent processing for that configuration must use the same O= value.
#3  the source tree being used for a remote build must be clean (use make mrproper)
BUILD_DIR=build_module

#jobs/threads for make proccess
NUM_THREAD=2
NUM_THREAD=12


#pbzip2 is used for Parallel uncompressing (speedup) if not instaleld, use normal tar xjf
#tar  xjf /usr/src/$LINUX_SOURCE.tar.bz2
tar  xf /usr/src/$LINUX_SOURCE.tar.bz2  --use-compress-program=pbzip2

#clean destination directory
rm -r $BUILD_DIR
mkdir $BUILD_DIR

cd ./$LINUX_SOURCE

#clean project source tree
make mrproper

#copy usefull files inside destination directory
cp /lib/modules/`uname -r`/build/.config ~/$BUILD_DIR/
cp /lib/modules/`uname -r`/build/Module.symvers ~/$BUILD_DIR/
cp /lib/modules/`uname -r`/build/Makefile ~/$BUILD_DIR/
# Just to remeber that /lib/modules/`uname -r`/build/ is a symbolic link to /usr/src/linux-headers-`uname -r`
# Module.symvers is neccerary. see paragraph 6, https://www.kernel.org/doc/Documentation/kbuild/modules.txt


#copy pem signature files
#https://docs.kernel.org/admin-guide/module-signing.html
#https://stackoverflow.com/questions/67670169/compiling-kernel-gives-error-no-rule-to-make-target-debian-certs-debian-uefi-ce
cp /usr/src/$LINUX_SOURCE/debian ~/$LINUX_SOURCE/ -r
cp /usr/src/$LINUX_SOURCE/debian.master ~/$LINUX_SOURCE/ -r


#start compiling
SECONDS=0
make O=../$BUILD_DIR outputmakefile
make O=../$BUILD_DIR archprepare -j $NUM_THREAD
#(If you encounter an error at this stage, run make mrproper and return to the last cp above and continue again from there)
make O=../$BUILD_DIR prepare -j $NUM_THREAD
make O=../$BUILD_DIR modules SUBDIRS=scripts -j $NUM_THREAD
make O=../$BUILD_DIR modules SUBDIRS=$MODULE_PATH -j $NUM_THREAD

make O=../build_module modules SUBDIRS=drivers/media/usb/uvc/ -j $NUM_THREAD

echo "Compilation took $SECONDS seconds"

modinfo ~/$BUILD_DIR/$MODULE_PATH/*.ko
# if everithing is fine, copy your new module in /lib/modules/`uname -r`/kernel/drivers/.....

