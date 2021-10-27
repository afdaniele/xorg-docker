# xorg-docker

Completely Dockerized instance of X server with support for HW acceleration from nVidia GPUs, OpenGL and Vulkan.

## How to build

You need `cpk` to build this project.
Install it from `pip3 install cpk`.

```shell
cpk build
```

## How to run

### Pick the GPU to use

You need to specify which GPU to use inside the container.
You can do so by passing the variable `BUS_ID`.
Use the following command to find a list of GPUs on your system
and take note of the `PCI BusID` of the GPU you want to use.

```shell
nvidia-xconfig --query-gpu-info
```

A good output looks like the following,

```text
GPU #1:
  Name      : GeForce GTX 1080 Ti
  UUID      : GPU-2e02c872-4cad-80d7-5128-780d01085bcb
  PCI BusID : PCI:129:0:0
```

In this case, the value for `BUS_ID` is `PCI:129:0:0`.


### Mounting graphics drivers

This repository supports only nvidia GPUs at this time.
You need the package `nvidia-docker2` installed for this to work.

The nvidia runtime for Docker mounts the GPU drivers from the host
so that you don't need them installed inside the container.
Though this runtime is designed for CUDA applications, so it doesn't
mount graphics libraries, we will need to do that manually.


### Run with OpenGL

```shell
cpk run -L opengl -- -e BUS_ID=PCI:129:0:0 --runtime=nvidia -v /usr/lib/x86_64-linux-gnu/nvidia/xorg/nvidia_drv.so:/usr/lib/xorg/modules/drivers/nvidia_drv.so -v /usr/lib/x86_64-linux-gnu/nvidia/xorg/libglxserver_nvidia.so:/usr/lib/xorg/modules/extensions/libglxserver_nvidia.so
```

### Run with Vulkan

```shell
cpk run -L vulkan -- -e BUS_ID=PCI:129:0:0 --runtime=nvidia -v /usr/lib/x86_64-linux-gnu/nvidia/xorg/nvidia_drv.so:/usr/lib/xorg/modules/drivers/nvidia_drv.so -v /usr/share/vulkan:/etc/vulkan
```