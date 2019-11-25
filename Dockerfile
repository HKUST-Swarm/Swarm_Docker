FROM ros:kinetic-perception

ENV CERES_VERSION="1.12.0"
ENV CATKIN_WS=/root/catkin_ws
ENV ROOTDIR=/root
ENV CUDADIR=/usr/local
ENV LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu/tegra:/usr/local/cuda/lib64:/usr/local/cuda-9.0/lib64:$LD_LIBRARY_PATH

ADD   ./VINS-Fusion-gpu/source.tar.gz  $ROOTDIR
RUN   echo $(ls -1 /root/) && pwd

      # set up thread number for building
RUN   if [ "x$(nproc)" = "x1" ] ; then export USE_PROC=1 ; \
      else export USE_PROC=$(($(nproc)/2)) ; fi && \
      chmod 1777 /tmp && apt-get update && apt-get install -y \
      cmake \
      libatlas-base-dev \
      libgoogle-glog-dev \
      libsuitesparse-dev \
      python-catkin-tools \
      openexr \
      libtbb-dev \
      ros-${ROS_DISTRO}-cv-bridge \
      ros-${ROS_DISTRO}-image-transport \
      ros-${ROS_DISTRO}-message-filters \
      ros-${ROS_DISTRO}-tf  && \
      rm -rf /var/lib/apt/lists/*  
      # Build and install Ceres
      #git clone https://ceres-solver.googlesource.com/ceres-solver && \
      #cd ceres-solver && \
      #git checkout tags/${CERES_VERSION} && \
      #mkdir build && cd build && \
      #cmake .. && \
      #make -j$(USE_PROC) install && \
      #rm -rf ../../ceres-solver && \
      #wget https://dl.dropboxusercontent.com/s/4xq9ajdypjgivb7/swarmDependsPart.tar.gz && \
      #tar -xf swarmDependsPart.tar.gz -C ~/ && \
# eigen3.3.4
WORKDIR $ROOTDIR
RUN   echo pwd && \
      dpkg --remove --force-depends libeigen3-dev && \
      #cd /root/ && pwd && \
      # tar -xf ./source.tar.gz && \
      # Install eigen3.3.4
      cd ./eigen-eigen-5a0156e40feb/build && \
      cmake .. && \
      make -j3 install && \
      #And then, we need old eigen back
      chmod 1777 /tmp && apt-get update && apt-get install -y libeigen3-dev &&\
      rm -rf /var/lib/apt/lists/* && \
      rm -rf ../../eigen-eigen-5a0156e40feb

# Install ceres solver
WORKDIR $ROOTDIR/ceres-solver/build
RUN   cmake ..    && \
      make -j3 install  && \
      rm -rf $ROOTDIR/ceres-solver && \
      mkdir -p $CATKIN_WS/src/VINS-Fusion-gpu/ &&\
      mkdir -p $CATKIN_WS/src/vision_opencv/ &&\
      mkdir -p $ROOTDIR/opencv_release/ &&\  
      mkdir -p $CUDADIR/cuda-9.0/ &&\
      rm -rf $ROOTDIR/source.tar.gz

# Copy VINS-Fusion-gpu
COPY ./VINS-Fusion-gpu/ $CATKIN_WS/src/VINS-Fusion-gpu/
COPY ./vision_opencv/ $CATKIN_WS/src/vision_opencv/
COPY ./opencv_release/ $ROOTDIR/opencv_release/
COPY ./cuda-9.0/ $CUDADIR/cuda-9.0/
ENV PATH="/usr/local/cuda-9.0/bin:${PATH}"

# Build VINS-Fusion-gpu
WORKDIR $CATKIN_WS
ENV TERM xterm
ENV PYTHONIOENCODING UTF-8
RUN catkin config \
      --extend /opt/ros/$ROS_DISTRO \
      --cmake-args \
        -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-9.0/lib64 \
        -DCMAKE_BUILD_TYPE=Release && \
    catkin build -j1 && \
    sed -i '/exec "$@"/i \
            source "/root/catkin_ws/devel/setup.bash"' /ros_entrypoint.sh
