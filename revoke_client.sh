#!/bin/bash

# First argument: VPN server identifier
# Second argument: Client identifier

REV_DIR_CA1=./vpn-ca1/ca1
CLIENT_CONFIGS_CA1=./vpn-ca1/client-configs-ca1/files

REV_DIR_CA2=./vpn-ca2/ca2
CLIENT_CONFIGS_CA2=./vpn-ca2/client-configs-ca2/files

# checking if two parameters are passed when calling sh script
if [ "$#" -ne 2 ]; then
    echo "Two parameters are required!"
    echo "Usage: ./make_config.sh <vpn-name> <client-name>"
    exit 1
fi

# check if vpn server name is correct
if [ "$1" = "vpn-ca1" ]; then
    REV_DIR=${REV_DIR_CA1}
    CLIENT_CONFIGS=${CLIENT_CONFIGS_CA2}
elif [ "$1" = "vpn-ca2" ]; then
    REV_DIR=${REV_DIR_CA2}
    CLIENT_CONFIGS=${CLIENT_CONFIGS_CA2}
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
boldRed=${bold}${red}
boldEndRed=${nc}${normal}
FILE="$REV_DIR/keys/"${2}.crt
FILENAME=${boldRed}${2}${boldEndRed}

if [ ! -f "$FILE" ]; then
    echo -e "Certificate for ${FILENAME} does not exist, nothing to revoke!"
    exit 1
fi

cd ${REV_DIR} || exit 1
# shellcheck disable=SC1091
source vars &&
    ./revoke-full "$2"

# if revocation has been successful, delete all client files
# and copy crl.pem to directory root
# shellcheck disable=SC2181
if [ "$?" = 2 ]; then
    ROOT="../.."

    # shellcheck disable=SC2086
    rm "keys/$2".* &&
        cp "keys/crl.pem" ${ROOT} &&
        cd ${ROOT} &&
        cd ${CLIENT_CONFIGS} &&
        rm "$2".ovpn &&
        echo -e ${boldRed}"Client revocation successfull!"${boldEndRed}
else
    exit 1
fi
