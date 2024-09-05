ARG dist=ubuntu-jammy
ARG gr_version=3.10.7.0
ARG repo=igorfreire
FROM ${repo}/gnuradio-oot-dev:${gr_version}-${dist}
# Build dependencies:
# - rtl-sdr: libusb-1.0-0-dev
# - gr-osmosdr: libosmosdr-dev
# Useful tools:
# - PlutoSDR: libiio-utils
# - USRP: uhd-host
# - BladeRF: bladerf
RUN apt-get install -y \
    libiio-utils \
    libosmosdr-dev \
    libusb-1.0-0-dev \
    uhd-host
RUN add-apt-repository -y ppa:nuandllc/bladerf && \
    apt update && \
    apt install -y bladerf \
    bladerf-firmware-fx3 \
    bladerf-fpga-hostedxa4
# RTL-SDR
RUN git clone https://github.com/osmocom/rtl-sdr.git && \
    cd rtl-sdr/ && mkdir build && cd build/ && \
    cmake -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON .. && \
    cmake --build . && \
    cmake --install . && \
    cd ../../ && rm -r rtl-sdr/
# gr-osmosdr
RUN git clone https://github.com/osmocom/gr-osmosdr && \
    cd gr-osmosdr/ && \
    mkdir build && cd build && \
    cmake -DENABLE_DOXYGEN=OFF .. && \
    cmake --build . -j$(nproc) && \
    cmake --install . && \
    ldconfig && \
    cd ../../ && rm -r gr-osmosdr/
# libbladerf
RUN apt remove -y libbladerf2 && \
    apt install -y libncurses5-dev && \
    git clone https://github.com/Nuand/bladeRF.git ./bladeRF && \
    cd ./bladeRF && \
    cd host/ && \
    mkdir -p build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DINSTALL_UDEV_RULES=ON ../ && \
    make && \
    make install && \
    ldconfig && \
    cd ../../../ && rm -r bladeRF/
# gr-bladeRF
RUN git clone https://github.com/Nuand/gr-bladeRF.git && \
    cd gr-bladeRF && \
    mkdir build && cd build && \
    cmake .. && \
    cmake --build . -j$(nproc) && \
    cmake --install . && \
    ldconfig && \
    cd ../../ && rm -r gr-bladeRF/