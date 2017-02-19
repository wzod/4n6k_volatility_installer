# volatility_installer.sh

Install Volatility 2.6 for Linux with one command.

##Background
Volatility is an open source framework for analyzing volatile memory (reference: http://www.volatilityfoundation.org/about ). This script installs volatility and all required dependencies leveraging the bash shell.

With this script, you can: 

1. Skip all of the dependency frustration
2. Build volatility and the required dependencies from source
3. Run the latest version of Volatility

##Requirements

An internet connection and a Debian-based Linux distribution. This script has been tested on stock Ubuntu 16.04 and Ubuntu 14.04. Some testing has been done to support SIFT Workstation 3.0.

##Capabilities

* Downloads, verifies, extracts, and installs source archives for everything you will need to complete a full installation of Volatility 2.6:
  * Volatility 2.6
  * diStorm3
  * Yara (+ magic module) + Yara-Python
  * PyCrypto
  * Python Imaging Library + Library Fixes
  * OpenPyxl
  * ujson
  * pytz
* Adds "vol.py" to your system PATH so that you can run Volatility from any location.

##Usage

Volatility will be installed to the directory you specify.

* From a terminal, run: 
  * `sudo bash volatility_installer.sh /home/$USER`

In the above example, the following directories will be created:

* /home/$USER/volatility_setup 
  * Contains dependency source code and the install_log.txt file.
* /home/$USER/volatility_2.6
  * Contains the Volatility 2.6 install.

##Installation

You can download the script from the following GitHub page:

https://raw.githubusercontent.com/wzod/volatility_installer/master/volatility_installer.sh

`SHA256 Hash: 95805fde782753dac6473221264d5ba21b006d84ff47014b53eb81876791881e`

Bottom Line?
------------
Don't be afraid of the terminal. Read the source for this script and understand how it works. Automation is acceptable only after you understand what is happening behind the scenes.

If you see a problem with the code or can suggest improvements, please add an issue for tracking (suggestions are always welcomed, too!).

##Credits
Thanks to the Volatility team for all of their contribtions and advancing the field of memory forensics. Go to http://www.volatilityfoundation.org for more info.

Special shout-out to @4n6k for the inspiration and contributions with 4n6k_volatility_installer.sh (see https://github.com/4n6k/4n6k_volatility_installer), which was the origination of a large portion of the volatility_installer script.  @4n6k's script was also the catalyst for putting together the installer script for MASTIFF (see https://github.com/wzod/wzod_mastiff_installer ).
