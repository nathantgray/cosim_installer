# cosim_installer
Installer scripts for installing HELICS 2.8.0 with GridLAB-D, ns-3, and Python on Linux. 

The script assumes that your system Python is version 3.9. This will be the case if you have Ubuntu 21.10. If this is not the case you will need to make appropriate edits to the install script.

The script will make the directory "~/cosim2_env" and all downloads and installs are confined to that folder.
You may add the activate script to the cosim2_env folder when finished and use it to activate the environment.

This script takes a long time to run so it helps to get it right the first time. The whole installation took me about 35 minutes on a virtual machine. About 10 minutes of the installation was to install HELICS, 5 for Xerces and GridLAB-D, and 20 for ns-3.
## Before running the installer you should do several things: 
1. install the prerequisites with the following:
```
sudo apt-get update
sudo apt-get upgrade
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
  libzmq3-dev \
  make \
  python3.9 \
  python3.9-dev \
  python3-pyqt5 \
  swig \
  mercurial \
  python3.9-distutils
  ```
  2. Check that the Python library and include paths are correct in the HELICS installation portion: 
  ```
  cmake \
  -DBUILD_PYTHON_INTERFACE=ON \
  -DPYTHON_INCLUDE_DIR=/usr/include/python3.9/ \
  -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.9.so \
  -DCMAKE_INSTALL_PREFIX=${HELICS_INSTALL_PATH} \
  -DHELICS_BUILD_CXX_SHARED_LIB=ON \
  ```
  
  If /usr/include/python3.9 or /usr/lib/x86_64-linux-gnu/libpython3.9.so do not exist the installation will fail.
  
  3. If you don't need ns-3 to be installed, remove it from the script. It is the last step after the GridLAB-D install. When I timed the ns-3 installation on a VM it took 20 minutes.
  4. It is helpful to record what you do exactly when doing the installation in case things don't go smoothly. If you do have to make changes for your system or improvements to the script that could help others please consider contributing to this repository.

## During Installation
When the GridLAB-D is finished building it will display if HELICS and other things were linked correctly. They will all say no except HELICS and Xerces will say YES. 
If you see `HELICS:..........NO`, then you have a problem.

## After installation
1. Copy these files (activate, and cosim2_installer.sh) into the new folder, 'cosim2_env', that was created.
2. In terminal, run `source ~/cosim2_env/activate` to activate the environment. This will make the programs available in your terminal session.

  a) If you don't want to do this every time, add the command at the end of your .bashrc file. You can open it easily with `nano ~/.bashrc`.
  
  b) If you ever want to deactivate the environment use `deactivate_cosim`.

3. Test if HELICS and GridLAB-D were installed and the environment is working with `gridlabd --version` and `helics_broker --version`. If they are installed it will tell you the version of each.

 
