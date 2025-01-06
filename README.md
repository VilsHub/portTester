# About script

Port testing scripts consist of 3 scripts:
 - **autoPortTest.sh**  : This script is used to test for outgoing connectivity to more than one servers
 - **singleServerPortTest** : This script is used to test for outgoing connectivity to single server


# Syntax

## autoPortTest.sh

The syntax for the sript usage is shown below

**./autoPortTest.sh -s /path/to/serverFile -p /path/to/portsFile [-l labelScriptFile] [-t telnet | nc]**

**WHERE**

- **-s**  : A required parameter, which specifies the file (new line sperated IPs) that has the list of the servers to be tested
- **-p**  : A required parameter, which specifies the file (new line sperated ports) that has the list of the ports to be tested against each server in the serverFile 
- **-l**  : An optional parameter, which specifies the defined script, that has the labels for the servers IPs in the serverFile. The default label script file is found in ./src/serverLabels and the syntax in the file should be used to defined other labels. 
- **-t**  : An optional parameter, which is used to specify the tool to be used for connectivity test, which could either be **telnet** or **nc** (Netcat) The default tool is telnet.

## singleServerPortTest.sh

The syntax for the script usage is shown below

**./singleServerPortTest.sh -h serverIP -p portFile [-t telnet | nc]**

**WHERE**

 
- **-h**  : A required parameter, which specifies the host IP to test the outgoing connectivity with.
- **-p**  : A required parameter, which specifies the file (new line sperated ports) that has the list of the ports to be tested against the host server specified by the '**-h**' parameter 
- **-t**  : An optional parameter, which is used to specify the tool to be used for connectivity test, which could either be **telnet** or **nc** (Netcat) The default tool is telnet.