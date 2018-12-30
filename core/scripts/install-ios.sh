#!/bin/sh

IOS_LIBS=../../ios/Libraries

cd $(dirname $0)/../ios
cargo lipo --release > /dev/null 2>&1
rm -rf $IOS_LIBS
mkdir $IOS_LIBS
mkdir $IOS_LIBS/Headers
cp target/universal/release/libvml.a $IOS_LIBS/libvml.a
cbindgen . -o $IOS_LIBS/Headers/libvml.h -l c > /dev/null 2>&1