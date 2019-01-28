
read -r -d '' CARGO_CONFIG << EOM
[target.aarch64-linux-android]
ar = ".NDK/arm64/bin/aarch64-linux-android-ar"
linker = ".NDK/arm64/bin/aarch64-linux-android-clang"

[target.armv7-linux-androideabi]
ar = ".NDK/arm/bin/arm-linux-androideabi-ar"
linker = ".NDK/arm/bin/arm-linux-androideabi-clang"

[target.i686-linux-android]
ar = ".NDK/x86/bin/i686-linux-android-ar"
linker = ".NDK/x86/bin/i686-linux-android-clang"
EOM

install: install-ios install-android

install-ios:
	scripts/install-ios.sh

install-android:
	scripts/install-android.sh

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
		echo "expected NDK_HOME to be defined. Probably located at ~/Library/Android/sdk/ndk-bundle"; \
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
