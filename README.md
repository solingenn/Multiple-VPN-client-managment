Multiple VPN client managment
==============================
Multiple VPN client managment is framework for easier managment of vpn clients on multiple vpn servers, it's assumed that you already have OpenVPN servers ready.
This template provides two certificate authority (CA) folders **vpn-ca1** and **vpn-ca2**, but if you have more VPN servers you can copy one of these folder templates
and rename it however you want. You can also rename these existing templates however you want.

**NOTE:** If you rename or add additional vpn CA's, you also must make changes to subfolders and shell scripts. That will be described in ```Shell scripts usage``` below.

****
### Shell scripts usage
```
./make_key.sh <vpn-name> <client-name>
./make_config.sh <vpn-name> <client-name>
./revoke_client.sh <vpn-name> <client-name>
```
First parameter is always VPN name, and then client name!

**Creating new keys (certificates), new clients and revoking clients certificate is done by these 3 scripts.**

**Permission of entire vpn directory is 700.**

### Shell scripts - adding additional certificate authority (CA) directory
If you want to add additional CA directory's for another VPN server you have to update shell scripts and refactor ```if``` statement as example below:

**make_config.sh**
```
# set additional path variables
KEY_DIR_CA3=./vpn-ca3/ca3/keys
OUTPUT_DIR_CA3=./vpn-ca3/client-configs-ca3/files
BASE_CONFIG_CA3=./vpn-ca3/client-configs-ca2/base_ca3.conf

# add additional elif statement
if [ "$1" = "vpn-ca1" ]; then
    BASE_CONFIG=${BASE_CONFIG_CA1}
    KEY_DIR=${KEY_DIR_CA1}
    OUTPUT_DIR=${OUTPUT_DIR_CA1}
elif [ "$1" = "vpn-ca2" ]; then
    BASE_CONFIG=${BASE_CONFIG_CA2}
    KEY_DIR=${KEY_DIR_CA2}
    OUTPUT_DIR=${OUTPUT_DIR_CA2}
############################################
elif [ "$1" = "vpn-ca3" ]; then            # <= additional check for new vpn-name
    BASE_CONFIG=${BASE_CONFIG_CA3}         #
    KEY_DIR=${KEY_DIR_CA3}                 #
    OUTPUT_DIR=${OUTPUT_DIR_CA3}           #
############################################
else
    echo "Incorrect vpn server name!"
    exit 1
fi
```

**make_key.sh**
```
# set additional path variables
BUILD_DIR_CA3=./vpn-ca3/ca3

# add additional elif statement
if [ "$1" = "vpn-ca1" ]; then
    BUILD_DIR=${BUILD_DIR_CA1}
elif [ "$1" = "vpn-ca2" ]; then
    BUILD_DIR=${BUILD_DIR_CA2}
############################################
elif [ "$1" = "vpn-ca3" ]; then            # <= additional check for new vpn-name
    BUILD_DIR=${BUILD_DIR_CA3}             #
############################################
else
    echo "Incorrect vpn server name!"
    exit 1
fi
```

**revoke_client.sh**
```
# set additional path variables
REV_DIR_CA3=./vpn-ca3/ca3
CLIENT_CONFIGS_CA3=./vpn-ca3/client-configs-ca3/files

# add additional elif statement
if [ "$1" = "vpn-ca1" ]; then
    REV_DIR=${REV_DIR_CA1}
    CLIENT_CONFIGS=${CLIENT_CONFIGS_CA2}
elif [ "$1" = "vpn-ca2" ]; then
    REV_DIR=${REV_DIR_CA2}
    CLIENT_CONFIGS=${CLIENT_CONFIGS_CA2} 
############################################
elif [ "$1" = "vpn-ca3" ]; then            # <= additional check for new vpn-name
    REV_DIR=${REV_DIR_CA3}                 #
    CLIENT_CONFIGS=${CLIENT_CONFIGS_CA3}   #
############################################
else
    echo "Incorrect vpn server name!"
    exit 1
fi
```
Basically, that way you can add as many new CA for VPN servers as you like.

****

### Creating client workflow 

**The following example will be creating vpn client for vpn-ca1 (vpn-ca1 folder).**
**Same procedure is used for creating vpn client for vpn-ca2 for other vpn server, only difference is that on the client name will be added "-ca2" at the end, e.g. client-ca2**

Make sure you configure the values your CA will use, you need to edit the ```vars``` file within ```vpn-ca1\ca1\``` directory. Open that file in your text editor:  
```nano vars```

Inside, you will find some variables that can be adjusted to determine how your certificates will be created. You only need to worry about a few of these.
Towards the bottom of the file, find the settings that set field defaults for new certificates. It should look like this:  
```
export KEY_COUNTRY="YourCountry"
export KEY_PROVINCE="YourProvince"
export KEY_CITY="YourCity"
export KEY_ORG="YourOrganzation"
export KEY_EMAIL="you@yourhost.yourdomain"
export KEY_OU="YourOrganizationalUnit"
```
Edit the values to whatever you'd prefer, but do not leave them blank.

### Step 1: Generate a Client Certificate and Key Pair
Following example assumes that vpn directory with multiple CA's is in home folder (~).

We will generate a single client key/certificate for this guide.
We will use ```client1``` as the value for our certificate/key pair for this guide.

Use the ```./make_key.sh``` command like this:

```
cd ~/vpn/
./make_key.sh vpn-ca1 client1
```
The defaults should be populated, so you can just hit ENTER to continue.

Generated files are saved in ```~/vpn/vpn-ca1/ca1/keys``` directory (**client1.crt, client1.csr, client1.key**).
 
### Step 2: Generate client configurations
Now we can generate a config for ```client1.crt``` and ```client1.key``` credentials.
Move into the root of the folder (```~/vpn/```) and using shell script:

```
cd ~/vpn/
./make_config.sh vpn-ca1 client1
```

First parameter is name of the VPN server, and the second parameter is the name of the client for whom we made certificate and key.

If everything went well, we should have a ```client1.ovpn``` file in our ```.../client-configs-ca1/files``` directory:

```
ls ~/vpn/vpn-ca1/client-configs-ca1/files
```

Output:
```
client1.ovpn
```
**NOTE**
For Windows client, open ```client1.ovpn``` file with text editor and comment these three lines:
```
script-security 2
up /etc/openvpn/update-resolv-conf
down /etc/openvpn/update-resolv-conf
```

### Step 3: Connect to server vpn-ca1
Connect to vpn-ca1 server, go to ```/etc/openvpn/client (or where you have stored clients configs)``` and copy one of the existing client configs and rename it ```client1``` (e.g. ```cp client client1```).

Restart openvpn:
```
sudo systemctl restart openvpn@server
```

**When creating vpn file for vpn-ca2, connect to vpn-ca2 server and go through the same process!**

### Step 4: Test client cofiguration

**Linux**

Go to ```~/vpn/vpn-ca1/client-configs-ca1/files``` and test ```client1.ovpn```.
You can connect to the VPN by just pointing the ```openvpn command``` to the client configuration file:
```
sudo openvpn client1.ovpn
```

**Windows**

The OpenVPN client application for Windows can be found on [OpenVPN's Downloads](https://openvpn.net/index.php/open-source/downloads.html) page.
After installing OpenVPN, copy the .ovpn file to:
```
C:\Program Files\OpenVPN\config
```
When you launch OpenVPN, it will automatically see the profile and makes it available.

Once OpenVPN is started, initiate a connection by going into the system tray applet and right-clicking on the OpenVPN applet icon. This opens the context menu. Select client1 at the top of the menu (that's our client1.ovpn profile) and choose Connect.

A status window will open showing the log output while the connection is established, and a message will show once the client is connected.

**Test connection**

This should connect you to your VPN server, and you should have access to internet. 
Go to https://www.myip.com/, your IP address should be the same as one of the VPN server.

### Step 5: Transferring Configuration to Client Devices
Copy ```client1.ovpn``` from ```~/vpn/vpn-ca1/client-configs-ca1/files``` to physical media(DVD, USB...) or copy ```.ovpn``` file to server (scp) to give ```.ovpn``` file to intended person. Never send ```.ovpn``` file with email or through Skype, for security reasons. If you have put it on server, delete configuration after intended person have retrieved it.

### Revoking Client Certificates
To revoke a client certificate to prevent further access to the VPN server, enter ```~/vpn/``` directory and call ```./revoke-client.sh``` script:
```
./revoke_client.sh vpn-ca1 client1
```
This will show some output, ending in error 23. This is normal and the process should have successfully generated the necessary revocation information, which is stored in a file called ```crl.pem``` within the keys subdirectory.

Also, message in red color will be printed: ```Client revocation successfull!```

All client files will be deleted by this process (**client1.crt, client1.csr, client1.key, client1.ovpn**) and ```crl.pem``` file will be automatically copied to ```~/vpn``` directory.

Transfer ```crl.pem``` to the ```/etc/openvpn/keys``` configuration directory on **vpn-ca1 server**.

Restart OpenVPN to implement the certificate revocation:
```
sudo systemctl restart openvpn@server
```

When done, delete ```crl.pem``` from ```~/vpn``` directory.

The client should now no longer be able to successfully connect to the server using the old credential.

To revoke additional clients, follow this process:
1. Generate a new certificate revocation list (```crl.pem```) by calling ```./revoke-client.sh <vpn-name> <client-name>```.
2. Copy the new certificate revocation list to the vpn-ca1 ```/etc/openvpn/keys``` directory
3. Restart the OpenVPN service.
4. Delete ```crl.pem``` from ```~/vpn``` directory.

This process can be used to revoke any certificates that you've previously issued for your server.

### For additional VPN setup information go to [Digital Ocean - Set Up an OpenVPN Server on Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-16-04#step-10-create-client-configuration-infrastructure) for additional references.
