FROM gcr.io/cloud-builders/javac:8

ARG FLUTTER_VERSION=2.8.1
ARG ANDROID_API_LEVEL=29
ARG GRADLE_VERSION=7.3.3

ENV ANDROID_HOME /android-sdk
ENV GRADLE_HOME /opt/gradle/gradle-${GRADLE_VERSION}

# Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Use unicode
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8

# Install Dependencies
RUN apt-get update && \
    apt-get install -y \
        git locales sudo openssh-client ca-certificates tar gzip parallel \
        zip unzip bzip2 gnupg curl wget

# Flutter
RUN curl https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz -o /flutter.tar.xz && \
	tar xf flutter.tar.xz && \
	rm flutter.tar.xz && \
# Android SDK tools
	curl https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -o android-sdk-tools.zip && \
	unzip -qq android-sdk-tools.zip -d $ANDROID_HOME && \
	rm android-sdk-tools.zip && \
# Gradle
	wget "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" && \
	unzip -qq gradle-*.zip -d /opt/gradle
	

ENV PATH $PATH:$GRADLE_HOME/bin:/flutter/bin:/flutter/bin/cache/dart-sdk/bin:$ANDROID_HOME/tools/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:/blackbox/bin

RUN yes | sdkmanager --licenses && \
	sdkmanager "cmdline-tools;latest" "platform-tools" "build-tools;28.0.3" "platforms;android-${ANDROID_API_LEVEL}" && \
	flutter config --no-analytics && \
	flutter precache --no-ios && \
	flutter doctor

ENTRYPOINT [ "bash" ]