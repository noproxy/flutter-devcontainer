ARG UBUNTU_VERSION=

FROM ubuntu:${UBUNTU_VERSION}

ARG ANDROID_SDK_TOOLS_VERSION=
ARG ANDROID_PLATFORM_VERSION=
ARG ANDROID_BUILD_TOOLS_VERSION=

# basic tools for development
USER root
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        language-pack-en \
        ssh-client \
        sudo \
        unzip \
        wget \
        zip \
        fish \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# non-root user
RUN useradd \
        --shell $(which fish) \
        -G sudo \
        -m -d /home/noproxy \
        noproxy \
    && sed -i -e 's/%sudo.*/%sudo\tALL=(ALL:ALL)\tNOPASSWD:ALL/g' /etc/sudoers \
    && touch /home/noproxy/.sudo_as_admin_successful
USER noproxy
RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" \
    && sed -i -e 's/OSH_THEME=.*/OSH_THEME="simple"/g' /home/noproxy/.bashrc

# install android sdk
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV ANDROID_SDK_ROOT=$ANDROID_HOME
ENV PATH=${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/emulator:${PATH}
ENV ANDROID_SDK_TOOLS_VERSION=${ANDROID_SDK_TOOLS_VERSION}
ENV ANDROID_PLATFORM_VERSION=${ANDROID_PLATFORM_VERSION}
ENV ANDROID_BUILD_TOOLS_VERSION=${ANDROID_BUILD_TOOLS_VERSION}

USER root
RUN chmod 777 /opt
WORKDIR /opt
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bc \
        build-essential \
        lcov \
        libglu1-mesa \
        libpulse0 \
        libsqlite3-0 \
        libstdc++6 \
        locales \
        openjdk-11-jdk \
        ruby-bundler \
        ruby-full \
        software-properties-common \
        # for x86 emulators
        libasound2 \
        libatk-bridge2.0-0 \
        libgdk-pixbuf2.0-0 \
        libgtk-3-0 \
        libnspr4 \
        libnss3-dev \
        libxss1 \
        libxtst6 \
        nodejs \
        npm \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

USER noproxy
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip -O android-sdk-tools.zip \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools/ \
    && unzip android-sdk-tools.zip -d ${ANDROID_HOME}/cmdline-tools/ \
    && rm android-sdk-tools.zip \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && yes | sdkmanager --licenses \
    && yes | sdkmanager platform-tools \
    && yes | sdkmanager \
        "platforms;android-$ANDROID_PLATFORM_VERSION" \
        "build-tools;$ANDROID_BUILD_TOOLS_VERSION" \
    && sdkmanager emulator


# RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME} \
#    && yes | flutter doctor --android-licenses \
#    && flutter config --enable-web
