#!/usr/bin/env bash

# error codes
# 0 - exited without problems
# 1 - parameters not supported were used or some unexpected error occurred
# 2 - OS not supported by this script
# 3 - installed version of gclone is up to date
# 4 - supported unzip tools are not available

set -e

#when adding a tool to the list make sure to also add its corresponding command further in the script
unzip_tools_list=('unzip' '7z' 'busybox')

usage() { echo "Usage: curl https://raw.githubusercontent.com/wiserain/gclone/master/install.sh | sudo bash" 1>&2; exit 1; }

if [[ $(id -u) -ne 0 ]]; then
    echo "Try again with root privilege"
    exit 1
fi

if [ -n "$1" ]; then
    tag_name="$1"
else
    tag_name=$(curl --silent https://api.github.com/repos/wiserain/gclone/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
fi

#create tmp directory and move to it with macOS compatibility fallback
tmp_dir=`mktemp -d 2>/dev/null || mktemp -d -t 'gclone-install.XXXXXXXXXX'`; cd $tmp_dir


#make sure unzip tool is available and choose one to work with
set +e
for tool in ${unzip_tools_list[*]}; do
    trash=`hash $tool 2>>errors`
    if [ "$?" -eq 0 ]; then
        unzip_tool="$tool"
        break
    fi
done  
set -e

# exit if no unzip tools available
if [ -z "${unzip_tool}" ]; then
    printf "\nNone of the supported tools for extracting zip archives (${unzip_tools_list[*]}) were found. "
    printf "Please install one of them and try again.\n\n"
    exit 4
fi

# Make sure we don't create a root owned .config/gclone directory #2127
export XDG_CONFIG_HOME=config



#detect the platform
OS="`uname`"
case $OS in
  Linux)
    OS='linux'
    ;;
  Darwin)
    OS='osx'
    ;;
  *)
    echo 'OS not supported'
    exit 2
    ;;
esac

OS_type="`uname -m`"
case $OS_type in
  x86_64|amd64)
    OS_type='amd64'
    ;;
  i?86|x86)
    OS_type='386'
    ;;
  arm*)
    OS_type='arm'
    ;;
  aarch64)
    OS_type='arm64'
    ;;
  *)
    echo 'OS type not supported'
    exit 2
    ;;
esac


#download and unzip
zip_file="gclone-${tag_name}-$OS-$OS_type.zip"
download_link="https://github.com/wiserain/gclone/releases/download/${tag_name}/${zip_file}"

curl -LO $download_link
unzip_dir="tmp_unzip_dir_for_gclone"
# there should be an entry in this switch for each element of unzip_tools_list
case $unzip_tool in
  'unzip')
    unzip -a $zip_file -d $unzip_dir
    ;;
  '7z')
    7z x $zip_file -o$unzip_dir
    ;;
  'busybox')
    mkdir -p $unzip_dir
    busybox unzip $zip_file -d $unzip_dir
    ;;
esac
    
cd $unzip_dir

#mounting gclone to environment

case $OS in
  'linux')
    #binary
    cp gclone /usr/bin/gclone.new
    chmod 755 /usr/bin/gclone.new
    chown root:root /usr/bin/gclone.new
    mv /usr/bin/gclone.new /usr/bin/gclone
    ;;
  'osx')
    #binary
    mkdir -p /usr/local/bin
    cp gclone /usr/local/bin/gclone.new
    mv /usr/local/bin/gclone.new /usr/local/bin/gclone
    ;;
  *)
    echo 'OS not supported'
    exit 2
esac


#update version variable post install
version=`gclone --version 2>>errors | head -n 1`

printf "\n${version} has successfully installed."
printf '\nNow run "gclone config" for setup.\n\n'
exit 0
