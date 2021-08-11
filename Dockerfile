ARG dist=ubuntu:focal
FROM $dist
ARG gr_version=3.9.2
RUN apt update && apt install -y software-properties-common
RUN add-apt-repository ppa:gnuradio/gnuradio-releases && \
	apt update && \
	DEBIAN_FRONTEND="noninteractive" apt install -y \
	cmake \
	doxygen \
	git \
	graphviz \
	gnuradio=$gr_version* \
	gnuradio-dev=$gr_version* \
	pkg-config \
	python3-pip \
	swig
RUN pip3 install pygccxml