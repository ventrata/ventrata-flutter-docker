FROM openjdk:11

ARG FLUTTER_VERSION=2.8.1
ARG ANDROID_API_LEVEL=30
ARG GRADLE_VERSION=7.3.3

ENV ANDROID_HOME /android-sdk
ENV ANDROID_SDK_ROOT /android-sdk
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
        zip unzip bzip2 gnupg curl wget net-tools

RUN cd /opt \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip -O android-commandline-tools.zip \
    && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && unzip -q android-commandline-tools.zip -d /tmp/ \
    && mv /tmp/cmdline-tools/ ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm android-commandline-tools.zip && ls -la ${ANDROID_SDK_ROOT}/cmdline-tools/latest/

ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin

#ENV PATH $PATH:$GRADLE_HOME/bin:/flutter/bin:/flutter/bin/cache/dart-sdk/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/tools/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:/blackbox/bin

RUN yes | sdkmanager --licenses
RUN yes | sdkmanager "emulator" "platform-tools"
RUN yes | sdkmanager --update --channel=0
RUN yes | sdkmanager \
    "platforms;android-30" \
    "build-tools;30.0.3" \
    "system-images;android-30;google_apis;x86"

ENV GRADLE_VERSION=7.3.3
ENV PATH=$PATH:"/opt/gradle/gradle-${GRADLE_VERSION}/bin"
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp \
    && unzip -d /opt/gradle /tmp/gradle-*.zip \
    && chmod +775 /opt/gradle \
    && gradle --version \
    && rm -rf /tmp/gradle*

ENTRYPOINT [ "/bin/bash" ]