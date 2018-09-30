#!/bin/bash

# First argument: VPN server identifier
# Second argument: Client identifier

BUILD_DIR_CA1=./vpn-ca1/ca1
BUILD_DIR_CA2=./vpn-ca2/ca2

# checking if two parameters are passed when calling sh script
if [ "$#" -ne 2 ]; then
    echo "Two parameters are required!"
    echo "Usage: ./make_config.sh <vpn-name> <client-name>"
    exit 1
fi

# check if vpn server name is correct
if [ "$1" = "vpn-ca1" ]; then
    BUILD_DIR=${BUILD_DIR_CA1}
elif [ "$1" = "vpn-ca2" ]; then
    BUILD_DIR=${BUILD_DIR_CA2}
else
    echo "Incorrect vpn server name!"
    exit 1
fi

# check if certificate for given name exists
# shellcheck disable=SC2086
bold=$(tput bold)
normal=$(tput sgr0)
red='\033[0;31m'
nc='\033[0m'
FILE="$BUILD_DIR/keys/"${2}.key
FILENAME=${bold}${red}${2}${nc}${normal}

if [ -f "$FILE" ]; then
    echo -e "Certificate for ${FILENAME} already exists!"
    exit 1
fi

cd ${BUILD_DIR} || exit 1
# shellcheck disable=SC1091
source vars
./build-key "$2"
