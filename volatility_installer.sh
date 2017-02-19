#!/bin/bash

# volatility_installer.sh
# v1.1.4 (20170219)
# Installs Volatility for Ubuntu Linux with one command.
# Run this script from the directory in which you'd like to install Volatility.
# Tested on stock Ubuntu 16.04 + 14.04 + SIFT 3
# More at https://github.com/wzod/volatility_installer + http://www.volatilityfoundation.org

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
ARCHIVES=('distorm3.zip' 'pycrypto-2.6.1.tar.gz' 'yara-v3.5.0.tar.gz' \
          'yara-python-v3.5.0.tar.gz' 'openpyxl-2.4.2.tar.gz' \
          'ujson-1.35.tar.gz' 'volatility-2.6.tar.gz')
HASHES=('c9f11253cfb69396f0d6aa711ecca6a0113c3d4ea550aa7bfae900271b0856b2' \
        'f2ce1e989b272cfcb677616763e0a2e7ec659effa67a88aa92b3a65528f60a3c' \
        '4bc72ee755db85747f7e856afb0e817b788a280ab5e73dee42f159171a9b5299' \
        'e0d564c1a8c98957eda9fb49d4259dcc24b868c98f07a8f2899f24e7bfde6d18' \
        '2fe9ba182b687acf7e4660b39bd91d703c0bf934f8295c182d04ecd2345c6e26' \
        'f66073e5506e91d204ab0c614a148d5aa938bdbf104751be66f8ad7a222f5f86' \
        '6e81c3e6023e7a90953948907448d40ce02e6806275b6fdf6769b01dc9acd7af' )

# Program usage dialog
usage() {
  echo -e "\nHere is an example of how you should run this script:"
  echo -e "  > sudo bash ${PROGNAME} /home/<username>"
  echo -e "Result: Volatility will be installed to /home/<username>/volatility_2.6"
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
    wget -o "${LOGFILE}" -O distorm3.zip "https://github.com/gdabah/distorm/archive/v3.3.4.zip" && \
    wget -o "${LOGFILE}" "https://pypi.python.org/packages/60/db/645aa9af249f059cc3a368b118de33889219e0362141e75d4eaf6f80f163/pycrypto-2.6.1.tar.gz" && \
    wget -o "${LOGFILE}" -O yara-v3.5.0.tar.gz "https://github.com/VirusTotal/yara/archive/v3.5.0.tar.gz" && \
    wget -o "${LOGFILE}" -O yara-python-v3.5.0.tar.gz "https://github.com/VirusTotal/yara-python/archive/v3.5.0.tar.gz" && \
    wget -o "${LOGFILE}" -O openpyxl-2.4.2.tar.gz "https://pypi.python.org/packages/56/c6/a2a7c36196e4732acceca093ce5961db907f5a855b557d6a727a7f59b8b4/openpyxl-2.4.2.tar.gz" && \
    wget -o "${LOGFILE}" -O ujson-1.35.tar.gz "https://pypi.python.org/packages/16/c4/79f3409bc710559015464e5f49b9879430d8f87498ecdc335899732e5377/ujson-1.35.tar.gz" && \
    wget -o "${LOGFILE}" -O volatility-2.6.tar.gz "https://github.com/volatilityfoundation/volatility/archive/2.6.tar.gz"
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
  apt-get update && apt-get install unzip tar -y
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
    cd distorm-3.3.4 && py_install
  # pycrypto
    cd pycrypto-2.6.1 && py_install
  # yara
    cd yara-3.5.0 && chmod +x bootstrap.sh && ./bootstrap.sh && \
      ./configure --enable-magic ; make ; make install && cd "${SETUP_DIR}"
  # yara-python
    cd yara-python-3.5.0 && python setup.py build --dynamic-linking && python setup.py install && cd "${SETUP_DIR}"
  # OpenPyxl
    cd openpyxl-2.4.2 && py_install
  # pytz
    easy_install --upgrade pytz
  # SIFT 3.0 check + fix
    sift_fix
  # Volatility
    mv -f volatility-2.6 .. ; cd ../volatility-2.6 && chmod +x vol.py && ldconfig
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
    automake build-essential gcc libbz2-dev libc6-dev libfreetype6-dev \
    libgdbm-dev libjansson-dev libjpeg8-dev libmagic-dev libreadline-gplv2-dev \
    libssl-dev libtool python-dev python-pillow python-setuptools zlib1g zlib1g-dev -y
}

# Shorthand for done message
done_msg() {
  phantom "Done."
}

# Check for SIFT 3.0 and fix
sift_fix() {
  if [[ -d /usr/share/sift ]]; then
    apt-get install libxml2 libxml2-dev libxslt1.1 libxslt1-dev -y
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
  status "Downloading Volatility 2.6 and dependency source code..."
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
