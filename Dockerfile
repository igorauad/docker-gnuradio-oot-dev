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
	gnuradio-dev=$gr_version* \
	python3-pip
RUN pip3 install pygccxml