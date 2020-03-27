FROM openjdk:8

ARG FLUTTER_VERSION=v1.12.13+hotfix.8
ARG DANGER_VERSION=6.3.1
ARG ANDROID_API_LEVEL=29

ENV ANDROID_HOME /android-sdk
# ENV ANDROID_NDK_HOME ${ANDROID_HOME}/ndk

RUN apt-get update && apt-get install -y \
	curl \
	git \
	make \
	ruby \
	unzip \
&& rm -rf /var/lib/apt/lists/*

# Flutter
RUN curl https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz --output /flutter.tar.xz && \
	tar xf flutter.tar.xz && \
	rm flutter.tar.xz && \
# Android SDK tools
	curl https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip --output android-sdk-tools.zip && \
	unzip -qq android-sdk-tools.zip -d $ANDROID_HOME && \
	rm android-sdk-tools.zip && \
# Android NDK
	# curl https://dl.google.com/android/repository/android-ndk-r21-darwin-x86_64.zip --output android-ndk.zip && \
	# unzip -qq -o android-ndk.zip -d $ANDROID_NDK_HOME && \
	# mv $ANDROID_NDK_HOME/android-ndk-r21/* $ANDROID_NDK_HOME && \
	# rm android-ndk.zip && \
# Danger
	gem install bundler --no-document

ENV PATH $PATH:/flutter/bin:/flutter/bin/cache/dart-sdk/bin:$ANDROID_HOME/tools/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:/blackbox/bin

RUN yes | sdkmanager --licenses && \
	sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools" "build-tools;28.0.3" "platforms;android-${ANDROID_API_LEVEL}"

RUN flutter config --no-analytics && \
	flutter precache --no-ios && \
	flutter doctor