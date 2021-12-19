ARG tag=3.9.4-ubuntu-focal
FROM igorfreire/gnuradio-oot-dev:$tag
# List of dependencies for your GR OOT module.
ARG deps
# OOT repository URL and name:
ARG oot_url
ARG oot_name
# Install dependencies
RUN apt-get install -y $deps
# Install the OOT module
RUN git clone $oot_url && \
    cd $oot_name && mkdir build && cd build/ && \
    cmake .. && \
    cmake --build . && \
    cmake --install . && \
    ldconfig && \
    cd ../../ && rm -r $oot_name