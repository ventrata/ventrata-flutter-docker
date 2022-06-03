FROM gcr.io/ventrata-flutter/android:latest

ARG FLUTTER_VERSION=3.0.1

ENV FLUTTER_HOME=/flutter

# Install Flutter
ENV PATH=${PATH}:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin
RUN git clone --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME}
RUN yes | flutter doctor --android-licenses \
    && flutter precache \
    && flutter config --no-analytics \
    && flutter doctor

ENTRYPOINT [ "/bin/bash" ]
