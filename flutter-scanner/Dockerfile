FROM sonarsource/sonar-scanner-cli:5.0.1

# Install Android and Flutter

ENV ANDROID_HOME="/usr/local/Android"
ENV ANDROID_SDK_ROOT="$ANDROID_HOME/sdk"
ENV PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"

# Prerequisites
RUN apk update && apk add curl git unzip xz zip mesa-gl openjdk11-jdk wget gcompat
RUN rm /var/cache/apk/*
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools /root/.android

# Install the Android SDK Dependency.
RUN set -eux; wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/android-sdk-tools.zip
RUN unzip -q /tmp/android-sdk-tools.zip -d /tmp/
RUN mv /tmp/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest/
RUN rm -rf /tmp/cmdline-tools
RUN touch /root/.android/repositories.cfg
RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses
RUN sdkmanager --sdk_root=${ANDROID_HOME} --install "platform-tools"
RUN sdkmanager --sdk_root=${ANDROID_HOME} --install "platforms;android-31" "build-tools;29.0.2"

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH "$PATH:/usr/local/flutter/bin"

# Run basic check to download Dart SDK
RUN flutter config --android-sdk=${ANDROID_SDK_ROOT}
RUN yes "y" | flutter doctor --android-licenses
RUN dart --disable-analytics
RUN flutter config --no-analytics --enable-android
RUN flutter doctor