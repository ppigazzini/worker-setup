#!/bin/bash
# install and configure fishtest worker

# fishtest credentials, cores to be contributed
echo "Write your fishtest username:"
read usr_name
echo "Write your fishtest password:"
read usr_pwd
echo "Write the number of cores to be contributed to fishtest:"
read n_cores

# update msys2 packages
pacman -Syuu --noconfirm

# install packages if not already installed
unzip -v &> /dev/null || pacman -S --noconfirm unzip
make -v &> /dev/null || pacman -S --noconfirm make
g++ -v &> /dev/null || pacman -S --noconfirm mingw-w64-x86_64-gcc
python3 --version &> /dev/null || pacman -S --noconfirm mingw-w64-x86_64-python3

# delete old worker
rm -rf worker
# download fishtest
tmp_dir=___${RANDOM}
mkdir ${tmp_dir} && pushd ${tmp_dir}
wget https://github.com/glinscott/fishtest/archive/master.zip
unzip master.zip fishtest-master/worker/*
pushd fishtest-master/worker
# setup a virtual environment
python3.exe -m venv "env"
env/bin/python3.exe -m pip install --upgrade pip setuptools wheel
env/bin/python3.exe -m pip install requests
# write fishtest.cfg
touch fish.exit
env/bin/python3.exe worker.py --concurrency "${n_cores}" "${usr_name}" "${usr_pwd}"
rm fish.exit

cat << EOF >> fishtest.cmd
@echo off
set PATH=C:\tools\msys64\mingw64\bin;C:\tools\msys64\usr\bin;%PATH%

env\bin\python3.exe -i worker.py
EOF

popd && popd
mv ${tmp_dir}/fishtest-master/worker .
rm -rf ${tmp_dir}
