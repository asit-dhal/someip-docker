FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
	apt-get install -y gcc build-essential && \
	apt-get install -y cmake \ 
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
	apt-utils

RUN apt-get install -y unzip unrar 

RUN  mkdir -p /root/vsomeip-build

RUN cd /root/vsomeip-build && \
    git clone https://github.com/GENIVI/capicxx-core-runtime.git && \
    git clone https://github.com/GENIVI/capicxx-core-tools.git && \
    git clone https://github.com/GENIVI/capicxx-someip-runtime.git && \
    git clone https://github.com/GENIVI/capicxx-someip-tools.git && \
    git clone https://github.com/GENIVI/vsomeip.git

RUN apt-get install -y libboost-all-dev

RUN cd /root/vsomeip-build/vsomeip && \
	rm -rf build && mkdir -p build && cd build && \
	cmake -D ENABLE_SIGNAL_HANDLING=1 -D CMAKE_INSTALL_PREFIX=/usr .. && \
	make && make install

RUN cd /root/vsomeip-build/capicxx-core-runtime && \
	git checkout 3.1.12.4 && \
	rm -rf build && mkdir -p build && cd build && \
	cmake -D CMAKE_INSTALL_PREFIX=/usr .. && \
	make && make install

RUN cd /root/vsomeip-build/capicxx-someip-runtime && \
	git checkout 3.1.12.12 && \
	rm -rf build && mkdir -p build && cd build && \
	cmake -D USE_INSTALLED_COMMONAPI=ON -D CMAKE_INSTALL_PREFIX=/usr .. && \
	make && make install

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get clean;

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME
 

