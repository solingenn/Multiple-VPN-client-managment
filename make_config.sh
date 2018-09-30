#!/bin/bash

# First argument: VPN server identifier
# Second argument: Client identifier

KEY_DIR_CA1=./vpn-ca1/ca1/keys
OUTPUT_DIR_CA1=./vpn-ca1/client-configs-ca1/files
BASE_CONFIG_CA1=./vpn-ca1/client-configs-ca1/base_ca1.conf

KEY_DIR_CA2=./vpn-ca2/ca2/keys
OUTPUT_DIR_CA2=./vpn-ca2/client-configs-ca2/files
BASE_CONFIG_CA2=./vpn-ca2/client-configs-ca2/base_ca2.conf

# checking if two parameters are passed when calling sh script
if [ "$#" -ne 2 ]; then
    echo "Two parameters are required!"
    echo "Usage: ./make_config.sh <vpn-name> <client-name>"
    exit 1
fi

# check if vpn server name is correct
if [ "$1" = "vpn-ca1" ]; then
    BASE_CONFIG=${BASE_CONFIG_CA1}
    KEY_DIR=${KEY_DIR_CA1}
    OUTPUT_DIR=${OUTPUT_DIR_CA1}
elif [ "$1" = "vpn-ca2" ]; then
    BASE_CONFIG=${BASE_CONFIG_CA2}
    KEY_DIR=${KEY_DIR_CA2}
    OUTPUT_DIR=${OUTPUT_DIR_CA2}
else
    echo "Incorrect vpn server name!"
    exit 1
fi

# check if certificate for given name exists
bold=$(tput bold)
normal=$(tput sgr0)
red='\033[0;31m'
nc='\033[0m'
FILE_CRT="$KEY_DIR"/"$2".crt
FILE_KEY="$KEY_DIR"/"$2".key
FILENAME=${bold}${red}${2}${nc}${normal}

# shellcheck disable=SC2086
if [ ! -f ${FILE_CRT} ] && [ ! -f ${FILE_KEY} ]; then
    echo -e "Certificate for ${FILENAME} does not exist!"
    exit 1
fi

# shellcheck disable=SC2086
cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${2}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${2}.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    >${OUTPUT_DIR}/${2}.ovpn

# shellcheck disable=SC2181
if [ "$?" = 0 ]; then
    echo "Client configuration created successfully!"
fi
