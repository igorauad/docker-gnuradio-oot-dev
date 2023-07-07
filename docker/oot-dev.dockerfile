ARG dist=ubuntu:jammy
FROM $dist
ARG dist
ARG gr_version=3.10.5.1
SHELL ["/bin/bash", "-c"]
RUN if [[ $dist == *"ubuntu"* ]]; then \
	apt update && apt install -y software-properties-common; \
	fi
RUN if [[ $dist == *"ubuntu"* ]]; then \
		add-apt-repository ppa:gnuradio/gnuradio-releases && \
		apt update && \
		DEBIAN_FRONTEND="noninteractive" apt install -y \
		clang-format \
		cmake \
		doxygen \
		gdb \
		gir1.2-gtk-3.0 \
		git \
		gnuradio=$gr_version* \
		gnuradio-dev=$gr_version* \
		graphviz \
		libspdlog-dev \
		libsndfile1-dev \
		pkg-config \
		python3-pip \
		swig; \
	elif [[ $dist == *"fedora"* ]]; then \
		dnf install -y \
		clang-tools-extra \
		cmake \
		doxygen \
		fftw-devel \
		gcc-c++ \
		gdb \
		git \
		gmp-devel \
		gnuradio-$gr_version* \
		gnuradio-devel-$gr_version* \
		graphviz \
		libsndfile-devel \
		pkg-config \
		pybind11-devel \
		python3-pip \
		spdlog-devel \
		swig; \
	fi
RUN pip3 install pygccxml
# Configure the paths required to run GR over python2 and python3
RUN if command -v python2 ; then \
	PYSITEDIR=$(python2 -m site --user-site) && \
	PYLIBDIR=$(python2 -c "from distutils import sysconfig; \
	print(sysconfig.get_python_lib(plat_specific=False, prefix='/usr/local'))") && \
	mkdir -p "$PYSITEDIR" && \
	echo "$PYLIBDIR" > "$PYSITEDIR/gnuradio.pth" ; fi
RUN PYSITEDIR=$(python3 -m site --user-site) && \
	PYLIBDIR=$(python3 -c "from distutils import sysconfig; \
	print(sysconfig.get_python_lib(plat_specific=False, prefix='/usr/local'))") && \
	mkdir -p "$PYSITEDIR" && \
	echo "$PYLIBDIR" > "$PYSITEDIR/gnuradio.pth"
