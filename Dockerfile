# parameters
ARG ARCH
ARG NAME
ARG ORGANIZATION
ARG DESCRIPTION
ARG MAINTAINER

# ==================================================>
# ==> Do not change the code below this line
ARG BASE_REGISTRY=docker.io
ARG BASE_ORGANIZATION=cpkbase
ARG BASE_REPOSITORY=ubuntu
ARG BASE_TAG=focal

# define base image
FROM ${BASE_REGISTRY}/${BASE_ORGANIZATION}/${BASE_REPOSITORY}:${BASE_TAG}-${ARCH} as BASE

# recall all arguments
# - current project
ARG NAME
ARG ORGANIZATION
ARG DESCRIPTION
ARG MAINTAINER
# - base project
ARG BASE_REGISTRY
ARG BASE_ORGANIZATION
ARG BASE_REPOSITORY
ARG BASE_TAG
# - defaults
ARG LAUNCHER=default

# define/create project paths
ARG PROJECT_PATH="${CPK_SOURCE_DIR}/${NAME}"
ARG PROJECT_LAUNCHERS_PATH="${CPK_LAUNCHERS_DIR}/${NAME}"
RUN mkdir -p "${PROJECT_PATH}"
RUN mkdir -p "${PROJECT_LAUNCHERS_PATH}"
WORKDIR "${PROJECT_PATH}"

# keep some arguments as environment variables
ENV \
    CPK_PROJECT_NAME="${NAME}" \
    CPK_PROJECT_DESCRIPTION="${DESCRIPTION}" \
    CPK_PROJECT_MAINTAINER="${MAINTAINER}" \
    CPK_PROJECT_PATH="${PROJECT_PATH}" \
    CPK_PROJECT_LAUNCHERS_PATH="${PROJECT_LAUNCHERS_PATH}" \
    CPK_LAUNCHER="${LAUNCHER}"

# install apt dependencies
COPY ./dependencies-apt.txt "${PROJECT_PATH}/"
RUN cpk-apt-install ${PROJECT_PATH}/dependencies-apt.txt

# install python3 dependencies
COPY ./dependencies-py3.txt "${PROJECT_PATH}/"
RUN cpk-pip3-install ${PROJECT_PATH}/dependencies-py3.txt

# install launcher scripts
COPY ./launchers/. "${PROJECT_LAUNCHERS_PATH}/"
COPY ./launchers/default.sh "${PROJECT_LAUNCHERS_PATH}/"
RUN cpk-install-launchers "${PROJECT_LAUNCHERS_PATH}"

# copy project root
COPY ./*.cpk ./*.sh ${PROJECT_PATH}/

# copy the source code
COPY ./packages "${CPK_PROJECT_PATH}/packages"

# build catkin workspace
RUN catkin build \
    --workspace ${CPK_CODE_DIR}

# define default command
CMD ["bash", "-c", "launcher-${CPK_LAUNCHER}"]

# store module metadata
LABEL \
    cpk.label.current="${ORGANIZATION}.${NAME}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.description="${DESCRIPTION}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.code.location="${PROJECT_PATH}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.base.registry="${BASE_REGISTRY}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.base.organization="${BASE_ORGANIZATION}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.base.project="${BASE_REPOSITORY}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.base.tag="${BASE_TAG}" \
    cpk.label.project.${ORGANIZATION}.${NAME}.maintainer="${MAINTAINER}"
# <== Do not change the code above this line
# <==================================================

ENV DISPLAY=:10
ENV VGL_DISPLAY=${DISPLAY}
ENV QT_X11_NO_MITSHM=1

# NOTE: uncomment this block if you want to install the nvidia drivers inside the container
#ENV NVIDIA_DRIVER_VERSION=460.91.03
#RUN wget https://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run
#RUN chmod +x ./NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run
#RUN ./NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run --accept-license --no-questions --ui=none --skip-depmod --no-drm --no-kernel-module

# install VirtualGL to forward calls from virtual framebuffer device to actual GPU
ENV VIRTUALGL_VERSION=2.6.5
COPY assets/virtualgl_${VIRTUALGL_VERSION}_amd64.deb ./virtualgl_${VIRTUALGL_VERSION}_amd64.deb
RUN dpkg -i virtualgl_${VIRTUALGL_VERSION}_amd64.deb

# nvidia runtime configuration
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all

RUN usermod -a -G lp,floppy,audio,video,cdrom,plugdev root

RUN apt update
RUN apt install -y i965-va-driver xserver-xorg-video-fbdev libgl1-mesa-dri
RUN apt install -y \
    libpam-systemd \
    libegl-mesa0 \
    libegl1-mesa-dev \
#    libgbm1 \
    libgl1-mesa-dev \
    libgl1-mesa-dri \
    libglapi-mesa \
    libgles2-mesa-dev \
    libglu1-mesa \
    libglu1-mesa-dev \
#    libglvnd-core-dev \
    libglx-mesa0 \
#    libwayland-egl1-mesa \
#    libwxgtk3.0-gtk3-0v5 \
    mesa-common-dev \
    mesa-utils \
    mesa-vulkan-drivers \
    xserver-xorg-video-nouveau


RUN apt install -y xserver-xorg-video-vesa
RUN apt install -y xserver-xorg-video-intel
RUN apt install -y policykit-1

RUN apt install -y \
    libvulkan1 \
    mesa-vulkan-drivers \
    vulkan-utils

# copy assets
COPY assets/xorg.nvidia.conf assets/xorg.nvidia.conf
COPY assets/xorg.generic.conf assets/xorg.generic.conf
COPY assets/xorg.generic2.conf assets/xorg.generic2.conf
