FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
	gcc build-essential cmake \
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
    openjdk-8-jdk \
    ant \
	ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/ && export JAVA_HOME

RUN  mkdir -p /root/vsomeip-build && \
	cd /root/vsomeip-build && \
    git clone https://github.com/GENIVI/capicxx-core-runtime.git && \
    git clone https://github.com/GENIVI/capicxx-core-tools.git && \
    git clone https://github.com/GENIVI/capicxx-someip-runtime.git && \
    git clone https://github.com/GENIVI/capicxx-someip-tools.git && \
    git clone https://github.com/GENIVI/capicxx-dbus-runtime && \
    git clone https://github.com/GENIVI/vsomeip.git

RUN wget http://dbus.freedesktop.org/releases/dbus/dbus-1.8.20.tar.gz && \
	tar -xzf dbus-1.8.20.tar.gz && cd dbus-1.8.20 && \
	patch -p1 < /root/vsomeip-build/capicxx-dbus-runtime/src/dbus-patches/capi-dbus-add-send-with-reply-set-notify.patch && \
	patch -p1 < /root/vsomeip-build/capicxx-dbus-runtime/src/dbus-patches/capi-dbus-add-support-for-custom-marshalling.patch && \
	patch -p1 < /root/vsomeip-build/capicxx-dbus-runtime/src/dbus-patches/capi-dbus-correct-dbus-connection-block-pending-call.patch && \
	./configure && make && make install && \
	export PKG_CONFIG_PATH="~/dbus-1.8.20"

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
	make && make install && \
	# capicxx-dbus-runtime
	cd /root/vsomeip-build/capicxx-dbus-runtime && \
	rm -rf build && mkdir -p build && cd build && \
	cmake .. && \
	make && make install

RUN wget https://github.com/GENIVI/capicxx-core-tools/releases/download/3.1.12.4/commonapi-generator.zip && \
	rm -rf ~/commonapi-generator && unzip commonapi-generator.zip -d ~/commonapi-generator && \
	chmod +x ~/commonapi-generator/commonapi-generator-linux-x86_64 && \
	rm -rf /bin/commonapi-generator && ln -s ~/commonapi-generator/commonapi-generator-linux-x86_64 /bin/commonapi-generator && \
	# dbus generator
	wget http://docs.projects.genivi.org/yamaica-update-site/CommonAPI/generator/3.1/3.1.3/commonapi_dbus_generator.zip && \
	rm -rf ~/commonapi-dbus-generator && unzip commonapi_dbus_generator.zip -d ~/commonapi-dbus-generator && \
	chmod +x ~/commonapi-dbus-generator/commonapi-dbus-generator-linux-x86_64 && \
	rm -rf /bin/commonapi-dbus-generator && ln -s ~/commonapi-dbus-generator/commonapi-dbus-generator-linux-x86_64 /bin/commonapi-dbus-generator && \
	# someip generator
	wget https://github.com/GENIVI/capicxx-someip-tools/releases/download/3.1.12.2/commonapi_someip_generator.zip && \
	rm -rf ~/commonapi-someip-generator && unzip commonapi_someip_generator.zip -d ~/commonapi-someip-generator && \
	chmod +x ~/commonapi-someip-generator/commonapi-someip-generator-linux-x86_64 && \
	rm -rf /bin/commonapi-someip-generator && ln -s ~/commonapi-someip-generator/commonapi-someip-generator-linux-x86_64 /bin/commonapi-someip-generator	
