define CARGO_CONFIG
[target.aarch64-linux-android]
ar = ".NDK/arm64/bin/aarch64-linux-android-ar"
linker = ".NDK/arm64/bin/aarch64-linux-android-clang"

[target.armv7-linux-androideabi]
ar = ".NDK/arm/bin/arm-linux-androideabi-ar"
linker = ".NDK/arm/bin/arm-linux-androideabi-clang"

[target.i686-linux-android]
ar = ".NDK/x86/bin/i686-linux-android-ar"
linker = ".NDK/x86/bin/i686-linux-android-clang"
endef

export CARGO_CONFIG:=$(CARGO_CONFIG)
export NDK_HOME=~/Library/Android/sdk/ndk-bundle
export JNI_LIBS=../android/core/src/main/jniLibs
export IOS_LIBS=../ios/Libraries

install: install-ios install-android

install-ios:
	@cargo lipo --release > /dev/null 2>&1
	@rm -rf $(IOS_LIBS)
	@mkdir $(IOS_LIBS)
	@mkdir $(IOS_LIBS)/Headers
	@cp target/universal/release/libvml.a $(IOS_LIBS)/libvml.a
	@cbindgen . -o $(IOS_LIBS)/Headers/libvml.h -l c > /dev/null 2>&1

install-android:
	@cargo build --target aarch64-linux-android --release > /dev/null 2>&1
	@cargo build --target armv7-linux-androideabi --release > /dev/null 2>&1
	@cargo build --target i686-linux-android --release > /dev/null 2>&1

	@rm -rf $(JNI_LIBS)
	@mkdir $(JNI_LIBS)
	@mkdir $(JNI_LIBS)/arm64
	@mkdir $(JNI_LIBS)/armeabi
	@mkdir $(JNI_LIBS)/x86

	@cp target/aarch64-linux-android/release/libvml.so $(JNI_LIBS)/arm64/libvml.so
	@cp target/armv7-linux-androideabi/release/libvml.so $(JNI_LIBS)/armeabi/libvml.so
	@cp target/i686-linux-android/release/libvml.so $(JNI_LIBS)/x86/libvml.so

setup: setup-rust setup-ios setup-android

setup-rust:
	@if [ ! -x ~/.cargo/bin/rustup ]; then curl https://sh.rustup.rs -sSf | sh; fi
	@if [ ! -x ~/.cargo/bin/cbindgen ]; then cargo install cbindgen; fi

setup-ios:
	@if [ ! -x /usr/bin/xcodebuild ]; then xcode-select --install; fi
	@if [ ! -x ~/.cargo/bin/cargo-lipo ]; then cargo install cargo-lipo; fi
	@rustup target add aarch64-apple-ios armv7-apple-ios armv7s-apple-ios x86_64-apple-ios i386-apple-ios

setup-android:
	@if [ ! -d $(NDK_HOME) ]; then \
		echo "Expect to find Android NDK at ~/Library/Android/sdk/ndk-bundle"; \
		exit 1; \
	fi

	@rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android

	@if [ ! -d ~/.NDK ]; then \
		mkdir ~/.NDK; \
		$(NDK_HOME)/build/tools/make_standalone_toolchain.py --api 26 --arch arm64 --install-dir ~/.NDK/arm64; \
		$(NDK_HOME)/build/tools/make_standalone_toolchain.py --api 26 --arch arm --install-dir ~/.NDK/arm; \
		$(NDK_HOME)/build/tools/make_standalone_toolchain.py --api 26 --arch x86 --install-dir ~/.NDK/x86; \
		echo "$${CARGO_CONFIG}" > ~/.cargo/config; \
	fi

clean:
	rm ~/.cargo/config
	rm -rf ~/.NDK
