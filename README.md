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
cpk run -L opengl -- -e BUS_ID=PCI:129:0:0 --runtime=nvidia -v /usr/lib/x86_64-linux-gnu/nvidia/xorg:/usr/lib/xorg/modules/drivers
```

### Run with Vulkan

```shell
cpk run -L vulkan -- -e BUS_ID=PCI:129:0:0 --runtime=nvidia -v /usr/lib/x86_64-linux-gnu/nvidia/xorg:/usr/lib/xorg/modules/drivers -v /usr/share/vulkan:/etc/vulkan
```


### Debug

If you want to find out whether a process successfully landed on the GPU and is not being run
using CPU rendering instead, use the command,

```shell
cat /sys/kernel/debug/dri/BUS_DEVICE_ID/clients
```

where `BUS_DEVICE_ID` is the number that appears in the `BUS_ID` variable, in the case shown above
`BUS_DEVICE_ID=129`.


### Troubleshooting

#### (EE) no screens found

When the X server inside the container dies with this message, it is very likely that it wasn't 
the display that it wasn't found but your GPU drivers.
In particular, make sure that you have this file on your host system
`/usr/lib/x86_64-linux-gnu/nvidia/xorg/nvidia_drv.so`.
If this file is not there, you either have installed the server version of the nvidia drivers 
(which do not carry graphics drivers), or it is somewhere else, if you find it, maybe with 
`locate nvidia_drv.so`, you can update the cpk command above accordingly.