#!/bin/bash

# 46nk_volatility_installer.sh
# v1.1.3 (10/31/2015)
# Installs Volatility for Ubuntu Linux with one command.
# Run this script from the directory in which you'd like to install Volatility.
# Tested on stock Ubuntu 12.04 + 14.04 + SIFT 3
# More at http://www.4n6k.com + http://www.volatilityfoundation.org

# Copyright (C) 2015 4n6k (4n6k.dan@gmail.com)
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Define constants
PROGNAME="${0}"
INSTALL_DIR="${1}"
SETUP_DIR="${INSTALL_DIR}"/"volatility_setup"
LOGFILE="${SETUP_DIR}"/"install_vol.log"
ARCHIVES=('distorm3.zip' 'pycrypto-2.6.1.tar.gz' 'yara-v3.4.0.tar.gz' \
          'setuptools-5.7.tar.gz' 'openpyxl-2.3.0.tar.gz' \
          'ipython-2.4.1.tar.gz' 'volatility-2.5.tar.gz'              )
HASHES=('f5b7a9f5f7fecae9a234f313d141d0348e58f02f4b5f82a137acb08969f87b78' \
        'f2ce1e989b272cfcb677616763e0a2e7ec659effa67a88aa92b3a65528f60a3c' \
        '528571ff721364229f34f6d1ff0eedc3cd5a2a75bb94727dc6578c6efe3d618b' \
        'a8bbdb2d67532c5b5cef5ba09553cea45d767378e42c7003347e53ebbe70f482' \
        '8ee71caa004e3aa1381d5bba748ada1b061be5126f2372ef90eeaab6386040bc' \
        '6d350b5c2d3e925b0ff6167658812d720b891e476238d924504e2f7f483e9217' \
        'b28ad483d4c0baf4b0b6a9162fcb497f6a822294be8b88621f678c15ed433d3d' )

# Program usage dialog
usage() {
  echo -e "\nHere is an example of how you should run this script:"
  echo -e "  > sudo bash ${PROGNAME} /home/4n6k"
  echo -e "Result: Volatility will be installed to /home/4n6k/volatility_2.5"
  echo -e "***NOTE*** Be sure to use a FULL PATH for the install directory.\n"
}

# Usage check; determine if usage should be printed
chk_usage() {
  if [[ "${INSTALL_DIR}" =~ ^(((-{1,2})([Hh]$|[Hh][Ee][Ll][Pp]$))|$) ]]; then
    usage ; exit 1
  elif ! [[ "${INSTALL_DIR}" =~ ^/.*+$ ]]; then
    usage ; exit 1
  else
    :
  fi
}

# Status header for script progress
status() {
  echo ""
  phantom "===================================================================="
  phantom "#  ${*}"
  phantom "===================================================================="
  echo ""
}

# Setup for initial installation environment
setup() {
  if [[ -d "${SETUP_DIR}" ]]; then
    echo "" ; touch "${LOGFILE}"
    phantom "Setup directory already exists. Skipping..."
  else
    mkdir -p "${SETUP_DIR}" ; touch "${LOGFILE}"
    echo "/usr/local/lib" >> /etc/ld.so.conf.d/volatility.conf
  fi
  cd "${SETUP_DIR}"
}

# Download Volatility and its dependencies
download() {
  if [[ -a "${ARCHIVES[7]}" && $(sha256sum "${ARCHIVES[7]}" | cut -d' ' -f1) \
    == "${HASHES[7]}" ]]; then
      phantom "Files already downloaded. Skipping..."
  else
    phantom "This will take a while. Tailing install_vol.log for progress..."
    tail_log
    wget -o "${LOGFILE}" -O distorm3.zip "https://github.com/gdabah/distorm/archive/v3.3.0.zip" && \
    wget -o "${LOGFILE}" "https://ftp.dlitz.net/pub/dlitz/crypto/pycrypto/pycrypto-2.6.1.tar.gz" && \
    wget -o "${LOGFILE}" -O yara-v3.4.0.tar.gz "https://github.com/plusvic/yara/archive/v3.4.0.tar.gz" && \
    wget -o "${LOGFILE}" "https://pypi.python.org/packages/source/s/setuptools/setuptools-5.7.tar.gz" && \
    wget -o "${LOGFILE}" -O openpyxl-2.3.0.tar.gz "https://bitbucket.org/openpyxl/openpyxl/get/2.3.0.tar.gz" && \
    wget -o "${LOGFILE}" -O ipython-2.4.1.tar.gz "https://pypi.python.org/packages/source/i/ipython/ipython-2.4.1.tar.gz" && \
    wget -o "${LOGFILE}" -O volatility-2.5.tar.gz "https://github.com/volatilityfoundation/volatility/archive/2.5.tar.gz"
    kill_tail
  fi
}

# Verify sha256 hashes of the downloaded archives
verify() {
  local index=0
  for hard_sha256 in "${HASHES[@]}"; do
    local archive ; archive="${ARCHIVES[$index]}"
    local archive_sha256 ; archive_sha256=$(sha256sum "${archive}" | cut -d' ' -f1)
    if [[ "$hard_sha256" == "$archive_sha256" ]]; then
      phantom "= Hash MATCH for ${archive}."
      let "index++"
    else
      phantom "= Hash MISMATCH for ${archive}. Exiting..."
      exit 0
    fi
  done
}

# Extract the downloaded archives
extract() {
  apt-get update && apt-get install unzip tar -y --force-yes
  for archive in "${ARCHIVES[@]}"; do
    local ext ; ext=$(echo "${archive}" | sed 's|.*\.||')
    if [[ "${ext}" =~ ^(tgz|gz)$ ]]; then
      tar -xvf "${archive}"
    elif [[ "${ext}" == "zip" ]]; then
      unzip "${archive}"
    else
      :
    fi
  done
} >>"${LOGFILE}"

# Install Volatility and its dependencies
install() {
  # Python
    aptget_install
  # distorm3
    cd distorm-3.3.0 && py_install
  # pycrypto
    cd pycrypto-2.6.1 && py_install
  # yara + yara-python
    cd yara-3.4.0 && chmod +x bootstrap.sh && ./bootstrap.sh && \
      ./configure --enable-magic ; make ; make install
    cd yara-python && py_install && ldconfig && cd "${SETUP_DIR}"
  # OpenPyxl
    cd setuptools-5.7 && python ez_setup.py && cd "${SETUP_DIR}"
    cd openpyxl-openpyxl-17ebc853f530 && py_install
  # pytz
    easy_install --upgrade pytz
  # iPython
    cd ipython-2.4.1 && py_install
  # SIFT 3.0 check + fix
    sift_fix
  # Volatility
    mv -f volatility-2.5 .. ; cd ../volatility-2.5 && chmod +x vol.py
    ln -f -s "${PWD}"/vol.py /usr/local/bin/vol.py
    kill_tail
} &>>"${LOGFILE}"

# Shorthand for make/install routine
make_install() {
  ./configure; make; make install; cd ..
}

# Shorthand for build/install Python routine
py_install() {
  python setup.py build install; cd ..
}

# Log script progress graphically
tail_log() {
  if [[ -d /usr/bin/X11 ]]; then
    xterm -e "tail -F ${LOGFILE} | sed "/kill_tail/q" && pkill -P $$ tail;" &
  else
  phantom "No GUI detected. Still running; not showing progress..."
  fi
}

# Kill the graphical script progress window
kill_tail() {
  echo -e "kill_tail" >> "${LOGFILE}"
}

# Install required packages from APT
aptget_install() {
  apt-get install \
    build-essential libreadline-gplv2-dev libjpeg8-dev zlib1g zlib1g-dev \
    libgdbm-dev libc6-dev libbz2-dev libfreetype6-dev libtool automake \
    python-dev libjansson-dev libmagic-dev python-pillow -y --force-yes
}

# Shorthand for done message
done_msg() {
  phantom "Done."
}

# Check for SIFT 3.0 and fix
sift_fix() {
  if [[ -d /usr/share/sift ]]; then
    apt-get install libxml2 libxml2-dev libxslt1.1 libxslt1-dev -y --force-yes
    pip install lxml --upgrade
  else
    :
  fi
}

# Text echo enhancement
phantom() {
  msg="${1}"
    if [[ "${msg}" =~ ^=.*+$ ]]; then 
      speed=".01" 
    else 
      speed=".03"
    fi
  let lnmsg=$(expr length "${msg}")-1
  for (( i=0; i <= "${lnmsg}"; i++ )); do
    echo -n "${msg:$i:1}" | tee -a "${LOGFILE}"
    sleep "${speed}"
  done ; echo ""
}

# Main program execution flow
main() {
  chk_usage
  setup
  status "Downloading Volatility 2.5 and dependency source code..."
    download && done_msg
  status "Verifying archive hash values..."
    verify && done_msg
  status "Extracting archives..."
    extract && done_msg
  status "Installing Volatility and dependencies..."
    phantom "This will take a while. Tailing install_vol.log for progress..."
      tail_log
      install ; done_msg
  status "Finished. You can now run "vol.py" from anywhere."
  phantom "Volatility location: ${PWD}"
  phantom "Dependency location: ${SETUP_DIR}"
  echo ""
}

main "$@"
