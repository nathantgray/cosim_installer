#! /bin/bash

download_helics() {
  echo "~~~~ Starting HELICS Download ~~~~"
  git clone https://github.com/GMLC-TDC/HELICS.git \
    --branch ${HELICS_BRANCH} --depth 1 --single-branch ${src_path}/helics${HELICS_BRANCH}
  echo "~~~~ Finished HELICS Download ~~~~"
}

install_helics() {
  echo "~~~~ Starting HELICS Install ~~~~"
  # Follow HELICS template and work in an empty building directory.
  cd ${src_path}/helics${HELICS_BRANCH}
  mkdir build
  cd build
  # Run cmake
  cmake \
    -DCMAKE_INSTALL_PREFIX=${env_path} \
    -DHELICS_BUILD_CXX_SHARED_LIB=ON \
    ..
    # HARD-CODE Python paths.

  # Make and install.
  make -j $(($(nproc) + 1)) && \
  make -j $(($(nproc) + 1)) install
  echo "~~~~ Finished HELICS Install ~~~~"
}

download_gridlabd() {
  echo "~~~~ Starting GridLAB-D Download ~~~~"
  mkdir ${src_path}/gridlab-d
  cd ${src_path}/gridlab-d
  # Shallowly clone the repository. Special sequence of commands in order
  # to only fetch the state of the repo at a single sha.
  # https://stackoverflow.com/a/43136160/11052174
  git init && \
    git remote add origin https://github.com/gridlab-d/gridlab-d.git && \
    git fetch --depth 1 origin ${GLD_BRANCH} && \
    git checkout FETCH_HEAD
  git submodule update --init
  echo "~~~~ Finished GridLAB-D Download ~~~~"
}

install_xerces(){
  echo "~~~~ Starting Xerces Install ~~~~"
  # Install Xerces.
  cd ${src_path}/gridlab-d/third_party
  perl -E "print '*' x 80" && \
    printf '\nInstalling Xerces...\n' && \
    tar -xzf xerces-c-3.2.0.tar.gz && \
    cd ${src_path}/gridlab-d/third_party/xerces-c-3.2.0 && \
    ./configure --prefix=${env_path} --disable-static CFLAGS=-O2 CXXFLAGS=-O2 && \
    make -j $(($(nproc) + 1)) && \
    make -j $(($(nproc) + 1)) install
  echo "~~~~ Finished Xerces Install ~~~~"
}

install_gridlabd() {
  echo "~~~~ Starting GridLAB-D Install ~~~~"
  # Install GridLAB-D
  cd ${src_path}/gridlab-d
  perl -E "print '*' x 80" && \
    printf '\nInstalling GridLAB-D...\n'
  mkdir cmake-build
  cd cmake-build
  cmake -DCMAKE_INSTALL_PREFIX=${env_path} -DGLD_USE_HELICS=ON -DHELICS_DIR=${env_path} -DCMAKE_VERBOSE_MAKEFILE=ON ..
  cmake --build . -j8 --target install
  #   autoreconf -isf && \
  #   ./configure --prefix=${env_path} --with-helics=${env_path} --with-xerces=${env_path} --enable-silent-rules 'CFLAGS=-g -O2 -w' 'CCFLAGS=-g -O2 -w' 'CXXFLAGS=-g -O2 -w -std=c++14' 'LDFLAGS=-g -O2 -w' && \
  #   make -j $(($(nproc) + 1)) && \
  #   make -j $(($(nproc) + 1)) install && \
  #   perl -E "print '*' x 80" && \
  #   printf "\nWe're all done building!\n"
  #   # http://gridlab-d.shoutwiki.com/wiki/Builds
  #   # http://gridlab-d.shoutwiki.com/wiki/Connection:helics_msg
  echo "~~~~ Finished GridLAB-D Install ~~~~"
}

download_ns3() {
  echo "~~~~ Starting ns-3 Download ~~~~"
  cd ${src_path}
  # (Shallowly) clone NS-3
  git clone https://gitlab.com/nsnam/ns-3-dev.git \
    --branch ${NS3_BRANCH} --depth 1 --single-branch ${src_path}/ns-3-dev-${NS3_BRANCH}
  cd ${src_path}/ns-3-dev-${NS3_BRANCH}
  # (Shallowly) clone helics-ns3
  #git clone https://github.com/GMLC-TDC/helics-ns3.git \
  #  --branch ${HELICS_NS3_BRANCH} --depth 1 --single-branch contrib/helics

  # Shallowly clone the repository. Special sequence of commands in order
  # to only fetch the state of the repo at a single sha.
  # https://stackoverflow.com/a/43136160/11052174
  mkdir contrib/helics
  cd contrib/helics

  git init && \
    git remote add origin https://github.com/GMLC-TDC/helics-ns3.git && \
    git fetch --depth 1 origin ${HELICS_NS3_BRANCH} && \
    git checkout FETCH_HEAD
  echo "~~~~ Finished ns-3 Download ~~~~"
}

install_ns3() {
  cd ${src_path}/ns-3-dev-${NS3_BRANCH}
  ./waf configure --prefix=${env_path} --with-helics=${env_path} --disable-werror --enable-examples --enable-tests
  ./waf build
}


mkdir ~/cosim3_env
export env_path=~/cosim3_env
mkdir ${env_path}/sources
export src_path=${env_path}/sources
# Software versions:
export HELICS_BRANCH=v3.2.1
#export GLD_BRANCH=7d2931eeb4c22520328cb02bad8dca1f13b74bb1 # Tip of develop as of 2021-05-07
# export GLD_BRANCH=107009aa8d94c1dc571e992849d4028474fde805 # Tip of develop as of 2021-10-23
# export GLD_BRANCH=b329624158b245bc3e409b007183e569303698ec  # Tip of develop as of 2022-06-21
# export GLD_BRANCH=feature/1279
export GLD_BRANCH=develop
export NS3_BRANCH=ns-3.35
# export HELICS_NS3_BRANCH=3d494d19fc7eb13c1dcbd6f57645bbf8a94d3c0a # Tip of main as of 2021-11-2
# export HELICS_NS3_BRANCH=3e5879e7b856ce03c83ce50b829965bd3c5d646b # Tip of main as of 2022-06-21
export HELICS_NS3_BRANCH=HELICS-v3.x-waf

# Where to put our built software?
export HELICS_INSTALL_PATH=${env_path}
export GLD_INSTALL_PATH=${env_path}

# Patch the Python path so it can find helics.py.
# export PYTHONPATH=${HELICS_INSTALL_PATH}/python

# GridLAB-D required environment variables:
export CXXFLAGS=-I${env_path}/share/gridlabd \
    GLPATH=${env_path}/lib/gridlabd:${env_path}/share/gridlabd \
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${env_path}/lib
    # No need to patch the path when using standard /usr/local location.
    # PATH=${PATH}:/usr/local/bin \
    # (Maybe) need to update the LD_LIBRARY_PATH so GridLAB-D can find
    # the HELICS libraries.
export PATH=${PATH}:${env_path}/bin
{
echo $(date)

download_helics
echo $(date)
install_helics
PYHELICS_INSTALL=~/cosim3_env
# Build GridLAB-D (and its dependency, Xerces)
echo $(date)
download_gridlabd

echo $(date)
# Install Xerces.
install_xerces

echo $(date)
# Install GridLAB-D
install_gridlabd
# cd ${src_path}/gridlab-d

echo $(date)
download_ns3
# Install NS-3
echo $(date)
install_ns3

echo $(date)
} > ${env_path}/cosim3_env.log
