FROM ubuntu:jammy AS builder

RUN useradd -m retdec
WORKDIR /home/retdec
ENV HOME /home/retdec

RUN apt-get -y update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y   \
	build-essential                                     \
	cmake                                               \
	git                                                 \
	python3                                             \
	doxygen                                             \
	graphviz                                            \
	upx                                                 \
	openssl                                             \
	libssl-dev                                          \
	zlib1g-dev                                          \
	autoconf                                            \
	automake                                            \
	pkg-config                                          \
	m4                                                  \
	libtool                                             \
	python-is-python3

USER retdec
RUN git clone https://github.com/avast/retdec && \
	cd retdec && \
	mkdir build && \
	cd build && \
	cmake .. -DCMAKE_INSTALL_PREFIX=/home/retdec/retdec-install -DCMAKE_BUILD_TYPE=Release && \
	make -j$(nproc) && \
	make install

FROM ubuntu:jammy

RUN useradd -m retdec
WORKDIR /home/retdec
ENV HOME /home/retdec

RUN apt-get update -y && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openssl graphviz upx python3

USER retdec

COPY --from=builder /home/retdec/retdec-install /retdec-install

ENV PATH /retdec-install/bin:$PATH
