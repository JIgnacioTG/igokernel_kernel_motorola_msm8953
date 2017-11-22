#!/bin/bash
kernel_version=${1}
kernel_name="DuskKernel"
device_name="addison"
zip_name="$kernel_name-$device_name-$kernel_version.zip"

export CONFIG_FILE="dusk_defconfig"
export ARCH="arm"
export CROSS_COMPILE="arm-eabi-"
export KBUILD_BUILD_USER="KuroIgunashio"
export KBUILD_BUILD_HOST="DuskKernel"
export TOOL_CHAIN_PATH="${HOME}/github/toolchains/arm-eabi-4.8/bin"
export CONFIG_ABS_PATH="arch/${ARCH}/configs/${CONFIG_FILE}"
export PATH=$PATH:${TOOL_CHAIN_PATH}
export objdir="${HOME}/github/DuskKernel/StockRom-7.1/obj"
export sourcedir="${HOME}/github/DuskKernel/StockRom-7.1"
export anykernel="${HOME}/github/DuskKernel/StockRom-7.1/anykernel"
release_folder="${HOME}/releases"

compile() {
  make O=$objdir ARCH=${ARCH} CROSS_COMPILE=${TOOL_CHAIN_PATH}/${CROSS_COMPILE}  $CONFIG_FILE -j8
  make O=$objdir -j8
}

clean() {
  make O=$objdir ARCH=${ARCH} CROSS_COMPILE=${TOOL_CHAIN_PATH}/${CROSS_COMPILE}  $CONFIG_FILE -j8
  make O=$objdir mrproper
}

module_stock() {
  rm -rf $anykernel/modules/
  mkdir $anykernel/modules
  find $objdir -name '*.ko' -exec cp -av {} $anykernel/modules/ \;
  # strip modules
 ${TOOL_CHAIN_PATH}/${CROSS_COMPILE}strip --strip-unneeded $anykernel/modules/*
  cp -rf $objdir/arch/${ARCH}/boot/zImage $anykernel/zImage
}

module_cm() {
  rm -rf $anykernel/modules/
  mkdir $anykernel/modules
  find $objdir -name '*.ko' -exec cp -av {} $anykernel/modules/ \;
  # strip modules
 ${TOOL_CHAIN_PATH}/${CROSS_COMPILE}strip --strip-unneeded $anykernel/modules/*
  cp -rf $objdir/arch/${ARCH}/boot/zImage $anykernel/zImage
}

delete_zip() {
  cd $anykernel
  find . -name "*.zip" -type f
  find . -name "*.zip" -type f -delete
}

build_package() {
  zip -r9 UPDATE-AnyKernel2.zip * -x README UPDATE-AnyKernel2.zip
}

make_name() {
  mv UPDATE-AnyKernel2.zip $zip_name
}
export_it() {
  rm zImage
  mv $zip_name $release_folder
}

turn_back() {
  cd $sourcedir
}

compile
module_stock
delete_zip
build_package
make_name
export_it
turn_back
