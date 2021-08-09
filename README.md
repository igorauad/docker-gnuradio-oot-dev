# GNU Radio OOT Development Environment

This image provides the environment for building and testing GNU Radio
out-of-tree (OOT) modules. There are various ways to use this image. For
example, it can be used to test an OOT module through Github workflows or
another continuous integration engine. Alternatively, it can be used directly
for development inside a container. One handy example for development is the
case of VSCode, explained below.

## Usage on Github Workflows

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
      image: igorfreire/gnuradio-oot-dev:3.9.2-ubuntu-focal
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

## Usage on a VSCode Devcontainer

You can use the image to develop your OOT module inside a container environment.
When using VSCode, this process is greatly simplified by using the [Remote -
Containers extension](https://code.visualstudio.com/docs/remote/containers). All
you need to do is install the extension, create a
`.devcontainer/devcontainer.json` file in your project, and reopen the workspace
inside the container. The `devcontainer.json` file should specify the image, as
follows:

```json
{
    "image": "igorfreire/gnuradio-oot-dev:tag"
}
```

where `tag` should be replaced by one of the available tags listed below:

- `3.7.11-ubuntu-bionic`
- `3.8.2-ubuntu-bionic`
- `3.9.2-ubuntu-focal`