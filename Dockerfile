FROM openjdk:11

ARG FLUTTER_VERSION=2.10.3
ARG ANDROID_API_LEVEL=31
ARG GRADLE_VERSION=6.7.1

ENV ANDROID_HOME /android-sdk
ENV ANDROID_SDK_ROOT /android-sdk
ENV GRADLE_HOME /opt/gradle/gradle-${GRADLE_VERSION}
ENV FLUTTER_HOME=/flutter

# Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Use unicode
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8

# Install Dependencies
RUN apt-get update && \
    apt-get install -y \
        git locales sudo openssh-client ca-certificates tar gzip parallel \
        zip unzip bzip2 gnupg curl wget net-tools

# Install Android command line tools
RUN cd /opt \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip -O android-commandline-tools.zip \
    && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && unzip -q android-commandline-tools.zip -d /tmp/ \
    && mv /tmp/cmdline-tools/ ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm android-commandline-tools.zip && ls -la ${ANDROID_SDK_ROOT}/cmdline-tools/latest/
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin

# Install Android SDKs
RUN yes | sdkmanager --licenses
# RUN yes | sdkmanager "emulator"
RUN yes | sdkmanager "platform-tools"
RUN yes | sdkmanager --update --channel=0
RUN yes | sdkmanager \
    "platforms;android-31" \
    "build-tools;29.0.2" \
    "android-30;google_apis;x86"

# Install Gradle
ENV PATH=$PATH:"/opt/gradle/gradle-${GRADLE_VERSION}/bin"
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp \
    && unzip -d /opt/gradle /tmp/gradle-*.zip \
    && chmod +775 /opt/gradle \
    && gradle --version \
    && rm -rf /tmp/gradle*

# Install Flutter
ENV PATH=${PATH}:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME}
RUN yes | flutter doctor --android-licenses \
    && flutter doctor

ENTRYPOINT [ "/bin/bash" ]