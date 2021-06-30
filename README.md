# cosim_installer
Installer scripts for installing HELICS with GLD, NS3, and Python on a fresh Ubuntu installation.

# WARNING: Carefully examine before using for yourself!
cosim_install.sh was written to be run on the root of a fresh installation of Ubuntu-20.04 on WSL2. It may work on more cases but has not been tested.
These scripts have not been tested properly. 

cosim_install.sh was written to be run as root user. It also assumes there is a user called "cosim" for the ns3 installation. You may wish to change this.

After installation I have added the following to .bashrc of the user:

```
export HELICS_BRANCH=v2.7.0
# Tip of develop as of 2021-05-07
export GLD_BRANCH=7d2931eeb4c22520328cb02bad8dca1f13b74bb1

# Where to put our built software?
export HELICS_INSTALL_PATH=/usr/local
export GLD_INSTALL_PATH=/usr/local

# Patch the Python path so it can find helics.py.
export PYTHONPATH=${HELICS_INSTALL_PATH}/python

# GridLAB-D required environment variables:
export CXXFLAGS="-I${GLD_INSTALL_PATH}/share/gridlabd"
export GLPATH=${GLD_INSTALL_PATH}/lib/gridlabd:${GLD_INSTALL_PATH}/share/gridlabd 
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${HELICS_INSTALL_PATH}/lib:/home/cosim/ns-3-dev/build/lib

# Add this line to use X Server with WSL2 
export DISPLAY=$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}'):0

# Aliases for launching Pycharm and Clion 
alias pycharm='/usr/share/pycharm-2021.1.1/bin/pycharm.sh > /dev/null 2>&1 &'
alias clion='/usr/share/clion-2021.1.1/bin/clion.sh > /dev/null 2>&1 &'
```
