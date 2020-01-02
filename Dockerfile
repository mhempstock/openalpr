FROM nvidia/cuda:10.2-devel-ubuntu16.04


RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository 'deb http://security.ubuntu.com/ubuntu xenial-security main'
RUN add-apt-repository ppa:ubuntu-toolchain-r/test && add-apt-repository ppa:ubuntu-toolchain-r/test


RUN  apt update && apt install -y gcc-6 g++-6 libxvidcore-dev libx264-dev \
libatlas-base-dev gfortran

RUN apt-get update && apt-get install -y build-essential \
cmake pkg-config unzip ffmpeg qtbase5-dev \
python-dev python3-dev python-numpy python3-numpy \
libhdf5-dev libgtk-3-dev libdc1394-22 libdc1394-22-dev \
libjpeg-dev libtiff5-dev  libavcodec-dev \
libavformat-dev libswscale-dev libxine2-dev libgstreamer-plugins-base1.0-0 \
libgstreamer-plugins-base1.0-dev libpng16-16 libpng-dev libv4l-dev \
libtbb-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev \
libtheora-dev libvorbis-dev libxvidcore-dev v4l-utils git \
 git cmake build-essential  \
 liblog4cplus-dev libcurl3-dev libcurl4-openssl-dev \
 liblog4cplus-dev beanstalkd openjdk-8-jdk && apt-get clean

RUN ln -s /usr/bin/gcc-6 /usr/local/cuda/bin/gcc && ln -s /usr/bin/g++-6 /usr/local/cuda/bin/g++

# ADD opencv_contrib opencv_contrib

RUN  git clone https://github.com/opencv/opencv.git && \
cd opencv && git checkout 3.4.0 && mkdir build && \
cd .. && git clone https://github.com/opencv/opencv_contrib.git && \
cd opencv_contrib && git checkout 3.4.0 && cd ../opencv/build && \
cmake -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_NVCUVID=ON -D FORCE_VTK=ON -D WITH_XINE=ON -D WITH_CUDA=ON -D WITH_OPENGL=ON -D WITH_TBB=ON -D WITH_OPENCL=ON -D CMAKE_BUILD_TYPE=RELEASE -D CUDA_NVCC_FLAGS="-D_FORCE_INLINES --expt-relaxed-constexpr" -D WITH_GDAL=ON -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules/ -D ENABLE_FAST_MATH=1 -D CUDA_FAST_MATH=1 -D WITH_CUBLAS=1 -D CXXFLAGS="-std=c++11" -DCMAKE_CXX_COMPILER=g++-6 -DCMAKE_C_COMPILER=gcc-6 .. && \
make -j "$(nproc)" && make install && rm -Rf /opencv /opencv_contrib

# RUN curl -L https://cppan.org/client/cppan-master-Linux-client.deb -o cppan-master-Linux-client.deb && \
# dpkg -i cppan-master-Linux-client.deb

RUN git clone https://github.com/DanBloomberg/leptonica.git && cd leptonica && \
 mkdir build && cd build && cmake .. && make && make install && rm -Rf /leptonica

RUN  apt-get install -y libtool automake

RUN curl -L https://github.com/tesseract-ocr/tesseract/archive/4.1.1.tar.gz -o tesseract.tar.gz && \
tar -xf tesseract.tar.gz
RUN cd tesseract-4.1.1 && ./autogen.sh 
RUN cd tesseract-4.1.1 && ./configure --prefix=$HOME/local/ --enable-shared
RUN cd tesseract-4.1.1 && make
RUN cd tesseract-4.1.1 && make install 
RUN rm -Rf /tesseract-4.1.1


RUN git clone https://github.com/openalpr/openalpr.git && mkdir openalpr/src/build && cd openalpr/src/build && \
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_INSTALL_SYSCONFDIR:PATH=/etc –DCOMPILE_GPU=6 -D WITH_GPU_DETECTOR=ON .. && \
make && make install && cd / && rm -Rf openalpr

COPY  openalpr.conf openalpr.conf

entrypoint ["alpr"]