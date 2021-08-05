ARG dist=ubuntu:focal
ARG gr_version=3.9.2
FROM $dist
RUN apt update && apt install -y software-properties-common
RUN add-apt-repository ppa:gnuradio/gnuradio-releases && \
	apt update && \
	apt install -y gnuradio-dev=$gr_version*
