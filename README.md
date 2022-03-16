# GNU Radio OOT Development Environment

This image provides an easy-to-use container environment for building, testing, and running GNU Radio out-of-tree (OOT) modules. There are many ways in which you can use this image. For example, you can use it as the base when building a dedicated container image for an OOT module. Also, you can use it to switch easily between GNU Radio versions and development environments. Furthermore, this image is adequate for usage on Github workflows, other continuous integration engines, VSCode development containers, and more. Please refer to the examples that follow.

- [GNU Radio OOT Development Environment](#gnu-radio-oot-development-environment)
  - [Base Image for your OOT Module](#base-image-for-your-oot-module)
  - [Multiple GNU Radio Versions in Parallel](#multiple-gnu-radio-versions-in-parallel)
  - [OOT Development Inside Container](#oot-development-inside-container)
  - [Github Workflows](#github-workflows)
  - [VSCode Devcontainer](#vscode-devcontainer)

## Base Image for your OOT Module

The following Dockerfile illustrates how the `gnuradio-oot-dev` image can serve as the base for building a dedicated image with your OOT module.

```Dockerfile
ARG tag=3.10.1-ubuntu-focal
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
```

Suppose the above Dockerfile is saved on a file named `oot.dockerfile`. In this case, for example, to build the [gr-dvbs2rx](https://github.com/igorauad/gr-dvbs2rx/) project, run:

```bash
docker build -f oot.dockerfile -t gr-dvbs2rx \
  --build-arg tag=3.9.4-ubuntu-focal \
  --build-arg deps="libusb-1.0-0-dev libosmosdr-dev libsndfile1-dev" \
  --build-arg oot_url=https://github.com/igorauad/gr-dvbs2rx/ \
  --build-arg oot_name=gr-dvbs2rx \
  .
```

After that, you can run your OOT inside the container while accessing an SDR interface directly from the container. Just make sure to use the correct options to access the SDR interface:

- USB interfaces: use option `--privileged -v /dev/bus/usb:/dev/bus/usb`.
- Network-connected interfaces: use option `--network host`.

For example, the `gr-dvbs2rx` image built earlier could be executed as follows:

```
docker run --rm -it --privileged -v /dev/bus/usb:/dev/bus/usb --network host dvbs2rx
```

Besides, the above Dockerfile is just a starting point. You can modify it easily to include other dependencies and tools. For a more advanced use case, refer to the actual [Dockerfile used on the gr-dvbs2rx project](https://github.com/igorauad/gr-dvbs2rx/blob/master/Dockerfile).

## Multiple GNU Radio Versions in Parallel

The `gnuradio-oot-dev` image can be a convenient solution to run multiple GNU Radio versions in parallel on reproducible environments.

To include the GUI, you can define aliases like so:

Linux
```bash
alias docker-gui='docker run --env="DISPLAY" -v $HOME/.Xauthority:/root/.Xauthority --network=host'
```

OSX
```bash
alias docker-gui='docker run --env="DISPLAY=host.docker.internal:0"'
```

And, in the case of OSX, you also need to authorize the container to access the host's X server:

```bash
xhost + localhost
```

After that, you can launch multiple containers with different GNU Radio
versions. For example, run the GR 3.8, 3.9, and 3.10 containers as follows:

```bash
docker-gui --rm -it --name gr3.8 igorfreire/gnuradio-oot-dev:3.8.2-ubuntu-bionic
```

```bash
docker-gui --rm -it --name gr3.9 igorfreire/gnuradio-oot-dev:3.9.4-ubuntu-focal
```

```bash
docker-gui --rm -it --name gr3.10 igorfreire/gnuradio-oot-dev:3.10.1-ubuntu-focal
```

Then launch `gnuradio-companion` inside each of them to verify it is working.

## OOT Development Inside Container

It is often useful to keep the OOT sources on the host while developing, building, and installing binaries inside the container. To do so, you can extend the commands explained in the previous section by adding a [bind mount option](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems). For example, suppose you have the OOT sources in your host at `$HOME/src/my-oot/`. Then, you could bind-mount this directory into the container as follows:

```bash
docker run --rm -it \
  -v $HOME/src/my-oot/:/src/my-oot/ \
  igorfreire/gnuradio-oot-dev:3.10.1-ubuntu-focal
```

In this case, option `-v $HOME/src/my-oot/:/src/my-oot/` will create a directory at `/src/my-oot/` inside the container, which you can use to access the OOT files. Any changes made in this directory are automatically reflected back to the host. For example, inside the container, build the OOT as follows:

```bash
cd /src/my-oot/
mkdir -p build/
cmake ..
make
```

## Github Workflows

The following snippet shows an example workflow configuration for an OOT module:

```yml
name: Test
on: [push, pull_request]
env:
  BUILD_TYPE: Release
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: igorfreire/gnuradio-oot-dev:3.10.1-ubuntu-focal
      env:
          PYTHONPATH: ${{github.workspace}}/build/python/bindings
    steps:
    - uses: actions/checkout@v2
    - name: Configure CMake
      run: cmake -B ${{github.workspace}}/build -DCMAKE_BUILD_TYPE=${{env.BUILD_TYPE}}
    - name: Build
      run: cmake --build ${{github.workspace}}/build --config ${{env.BUILD_TYPE}}
    - name: Test
      run: cd ${{github.workspace}}/build && ctest -C ${{env.BUILD_TYPE}} -VV
```

For example, refer to the workflow used on [gr-dvbs2rx](https://github.com/igorauad/gr-dvbs2rx/blob/master/.github/workflows/test.yml).

## VSCode Devcontainer

Development inside containers is greatly simplified on VSCode by using the [Remote - Containers extension](https://code.visualstudio.com/docs/remote/containers). All you need to do is install the extension, create a `.devcontainer/devcontainer.json` file in your project, and reopen the workspace inside the container. The `devcontainer.json` file should specify the image, as follows:

```json
{
  "image": "igorfreire/gnuradio-oot-dev:tag"
}
```

where `tag` should be replaced by one of the available tags listed below:

- `3.7.11-ubuntu-bionic`
- `3.8.2-ubuntu-bionic`
- `3.9.4-ubuntu-focal`
- `3.10.1-ubuntu-focal`

Furthermore, if you would like to run GUI applications (e.g., gnuradio-companion) directly from the VSCode terminal, you can append the following to your `devcontainer.json` file:

Linux
```json
{
  ...
  "runArgs": [
    "-v $HOME/.Xauthority:/root/.Xauthority --network=host"
	],
  "containerEnv": {
    "DISPLAY": "$DISPLAY"
  }
}
```

OSX
```json
{
  ...
  "containerEnv": {
    "DISPLAY": "host.docker.internal:0"
  }
}
```