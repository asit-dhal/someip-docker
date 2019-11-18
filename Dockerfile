FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    gcc build-essential \
    software-properties-common \
    cmake \
    git \
    libsystemd-dev \
    graphviz \
    vim \
    curl \
    net-tools \
    inetutils-ping \
    wget \
    gdb  \
    sudo \
    tcpdump  \
    apt-utils \
    unzip unrar \
    libboost-all-dev \
    maven

RUN add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    update-java-alternatives -s java-1.8.0-openjdk-amd64

RUN export JAVA_HOME="$(dirname $(dirname $(readlink -f $(which java))))"

RUN  mkdir -p /root/vsomeip-build && \
    cd /root/vsomeip-build && \
    git clone https://github.com/GENIVI/capicxx-core-runtime.git && \
    git clone https://github.com/GENIVI/capicxx-core-tools.git && \
    git clone https://github.com/GENIVI/capicxx-someip-runtime.git && \
    git clone https://github.com/GENIVI/capicxx-someip-tools.git && \
    git clone https://github.com/GENIVI/vsomeip.git

RUN cd /root/vsomeip-build/capicxx-core-tools/org.genivi.commonapi.core.releng && \
    mvn -Dtarget.id=org.genivi.commonapi.core.target clean verify && \
    mkdir -p /usr/local/bin/commonapi-generator && \
    unzip -d /usr/local/bin/commonapi-generator /root/vsomeip-build/capicxx-core-tools/org.genivi.commonapi.core.cli.product/target/products/commonapi-generator.zip && \
    chmod +x /usr/local/bin/commonapi-generator/commonapi-generator-linux-x86_64

RUN cd /root/vsomeip-build/capicxx-someip-tools/org.genivi.commonapi.someip.releng && \
    mvn clean verify -DCOREPATH=/root/vsomeip-build/capicxx-core-tools -Dtarget.id=org.genivi.commonapi.someip.target && \
    mkdir -p /usr/local/bin/commonapi-someip-generator && \
    unzip -d /usr/local/bin/commonapi-someip-generator /root/vsomeip-build/capicxx-someip-tools/org.genivi.commonapi.someip.cli.product/target/products/commonapi_someip_generator.zip && \
    chmod +x /usr/local/bin/commonapi-someip-generator/commonapi-someip-generator-linux-x86_64

RUN cd /root/vsomeip-build/vsomeip && \
    rm -rf build && mkdir -p build && cd build && \
    cmake -D ENABLE_SIGNAL_HANDLING=1 -D CMAKE_INSTALL_PREFIX=/usr .. && \
    make && make install && \
    # capicxx--core-runtime
    cd /root/vsomeip-build/capicxx-core-runtime && \
    rm -rf build && mkdir -p build && cd build && \
    cmake -D CMAKE_INSTALL_PREFIX=/usr .. && \
    make && make install && \
    # capicxx-someip-runtime
    cd /root/vsomeip-build/capicxx-someip-runtime && \
    rm -rf build && mkdir -p build && cd build && \
    cmake -D USE_INSTALLED_COMMONAPI=ON -D CMAKE_INSTALL_PREFIX=/usr .. && \
    make && make install

ENV PATH="/usr/local/bin/commonapi-generator:/usr/local/bin/commonapi-someip-generator/:${PATH}"
