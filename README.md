4n6k_volatility_installer.sh
============================

Install Volatility 2.4 for Linux automatically.

What Is It?
-----------
4n6k_volatility_installer.sh is a bash script that installs Volatility 2.4 (and all dependencies) for Ubuntu Linux with one command.

Why Do I Need It?
-----------------
Compiling source on Linux can be a pain. Dependency hunting wastes time and drives people away from considering Linux builds of cross-platform software. With this script, you can (1) skip all of the dependency frustration, (2) get right into using the newest version of Volatility, and (3) leverage the arguably more powerful and versatile *nix shell. No longer do you have to worry about whether or not you "have everything."

What's Required?
----------------
An internet connection and an APT-based Linux distribution [for the time being]. This script has been tested on stock Ubuntu 12.04 and Ubuntu 14.04.

What Does It Do?
----------------
Specifically, 4n6k_volatility_installer.sh does the following:

* Downloads, verifies, extracts, and installs source archives for everything you will need to complete a full installation of Volatility 2.4:
  * Volatility 2.4
  * diStorm3
  * Yara (+ magic module) + Yara-Python
  * PyCrypto
  * Python Imaging Library + Library Fixes
  * OpenPyxl
  * IPython
  * pytz
* Adds "vol.py" to your system PATH so that you can run Volatility from any location.

How Do I Use It?
----------------
From a terminal, run: `sudo bash 4n6k_volatility_installer.sh`

Where Can I Download It?
------------------------
You can download the script from this Github page or by right clicking and saving [this link](https://dl.4n6k.com/p/volinux/4n6k_volatility_installer.sh). 

Bottom Line?
------------
Don't be afraid of the terminal. Read the source for this script and understand how it works. Automation is acceptable only after you understand what is happening behind the scenes.

I'm open to making this script better. If you see a problem with the code or can suggest improvements, let me know and I'll see what I can do.

Thanks to the Volatility team for writing an amazing tool. Go to http://www.volatilityfoundation.org for more info.
