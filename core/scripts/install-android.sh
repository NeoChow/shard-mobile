#!/bin/sh

JNI_LIBS=../../android/core/src/main/jniLibs

cd $(dirname $0)/../android
cargo build --target aarch64-linux-android --release > /dev/null 2>&1
cargo build --target armv7-linux-androideabi --release > /dev/null 2>&1
cargo build --target i686-linux-android --release > /dev/null 2>&1

rm -rf $JNI_LIBS
mkdir $JNI_LIBS
mkdir $JNI_LIBS/arm64-v8a
mkdir $JNI_LIBS/armeabi-v7a
mkdir $JNI_LIBS/x86

cp target/aarch64-linux-android/release/libshard.so $JNI_LIBS/arm64-v8a/libshard.so
cp target/armv7-linux-androideabi/release/libshard.so $JNI_LIBS/armeabi-v7a/libshard.so
cp target/i686-linux-android/release/libshard.so $JNI_LIBS/x86/libshard.so
