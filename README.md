# cosim_installer
Installer scripts for installing HELICS with GLD, NS3, and Python on Linux. 

The script will make the directory "~/cosim2_env" and all downloads and installs are confined to that folder.
You may add the activate script to the cosim2_env folder when finished and use it to activate the environment.

Before running the installer you should install the prerequisites with the following:
```
sudo apt-get update
sudo apt-get install -y \
  autoconf \
  automake \
  build-essential \
  cmake \
  g++ \
  gcc \
  git \
  libboost-dev \
  libboost-filesystem-dev \
  libboost-program-options-dev \
  libboost-test-dev \
  libtool \
  libzmq5-dev \
  make \
  python3.9 \
  python3.9-dev \
  python3-pyqt5 \
  swig \
  mercurial \
  qt5-default
  ```
