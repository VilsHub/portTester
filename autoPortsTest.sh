#!/bin/bash

#Call using the format scriptName -s serverFile -p portsFile -l labelScript [-t telnet | nc]

timeout=7

# _________________Functions definitions starts_____________
function fileExist (){

    file=$1

    if [ ! -f $file ]; then
        echo -e "The file '$file' does not exist, please confirm and try again\n"
        exit 2
    fi

}
# _________________Functions definitions ends_______________

# Check if needed utilities are installed
which telnet > /dev/null 2> /dev/null
ec1=$?

which nc > /dev/null 2> /dev/null
ec2=$?


if [[ $ec1 -eq 1 && $ec2 -eq 1 ]]; then

    echo -e "\nNo Telnet and Netcat utilities installed, try installing one\n"
    exit

elif [[ $ec1 -eq 0 && $ec2 -eq 1 ]]; then

    if [ $tool == "nc" ]; then
        echo -e "\nNo Netcat utility installed, Telnet utility has been set as default\n"
        tool="telnet"
    fi

elif [[ $ec1 -eq 1 && $ec2 -eq 0 ]]; then

    if [ $tool == "telnet" ]; then
        echo -e "\nNo Telnet utility installed, Netcat utility has been set as default\n"
        tool="nc"
    fi

fi
serverFile=""
portFile=""
tool="telnet"
labelScript=""
while getopts "s:p:t:l:" variable; do
case "$variable" in
    s)
        serverFile=$OPTARG
        fileExist $serverFile
    ;;
    p)
        portFile=$OPTARG
        fileExist $serverFile
    ;;
    t)
        tool=$OPTARG
        if [[ $tool != "nc" && $tool != "telnet" ]]; then
            echo -e "Only telnet and nc utility is supported, '$tool' is not supported, and has been defaulted to telnet utility\n"
            tool="telnet"
        fi
    ;;
esac
done

# Check if the server and port file has been specified
if [[ -z $serverFile && -z $portFile ]]; then
    echo -e "Please specify the serverFile and the portFile, using '-s' and '-p' option respectively, and try again\n"
    exit 2
elif [[ ! -z $serverFile && -z $portFile ]]; then
    echo -e "Please specify the portFile, using '-p' option and try again\n"
    exit 2
elif [[ -z $serverFile && ! -z $portFile ]]; then
    echo -e "Please specify the serverFile, using '-s' option and try again\n"
    exit 2
fi

read -p "Would you like to use banks label script? (Y/N) : " useLabel

if [[ $useLabel = "y" || $useLabel = "Y" ]]; then
    res=0
    while [ $res -eq 0 ]; do
        read -p "Please supply the script name : " sName

        if [ -z $sName ];then
            res=1
            break
        fi

        if [ -f $sName ]; then
            labelScript=$sName
            res=1
        else
            echo "The script '$sName' could not be located, confirm the script name and try again or leave blank and press Enter to skip using script label"
        fi
    done
fi

if [ -z $labelScript ]; then
    declare -A banks
else
    # _________________Banks labels starts________________
    source $labelScript
    #________________Banks labels ends___________________
fi

# read in servers IP and ports
readarray -t servers < $serverFile
readarray -t ports < $portFile
echo -e "\nThe ports are being tested with $tool utility\n"


if [ ! -d "./output" ]; then
    mkdir ./output
fi

for server in ${servers[@]}; do

    # Parse Data
    trimmed_server="${server#"${server%%[![:space:]]*}"}"
    trimmed_server="${trimmed_server%"${trimmed_server##*[![:space:]]}"}"

    echo -e "NOW TESTING PORTS CONNECTIVITY WITH ${banks["$trimmed_server"]}($trimmed_server)\n"

    if [ ! -z $labelScript ]; then
        # Remove space if available from label
        label=$(echo "${banks["$trimmed_server"]}" | sed 's/ /_/g')
        output="./output/${label}_Ports_test_result.txt"
    else
        output="./output/${trimmed_server}_Ports_test_result.txt"
    fi


    echo "PORTS CONNECTIVITY TEST WITH ${banks["$trimmed_server"]}($trimmed_server) RESULT" > $output
    echo -e "\n" >> $output
    echo -e "PORTS\t----------\tSTATE" >> $output

    for port in ${ports[@]}; do

        # Parse Data
        trimmed_port="${port#"${port%%[![:space:]]*}"}"
        trimmed_port="${trimmed_port%"${trimmed_port##*[![:space:]]}"}"

        echo "Testing connectivity with ${banks["$trimmed_server"]}($trimmed_server) on port $trimmed_port"

        if [ $tool == "telnet" ]; then
            timeout --foreground $timeout telnet $trimmed_server $trimmed_port > temp_output
            cat temp_output | grep -i connected > /dev/null
            ec=$?
        elif [ $tool == "nc" ]; then
            nc -w $timeout $trimmed_server $trimmed_port
            ec=$?
        fi

        if [ $ec -eq 0 ]; then
            echo -e "Exit code: $ec, Connected succesfully\n"
            echo -e "$trimmed_port\t----------\tConnected successfully" >> $output
        elif [ $ec -ne 0 ]; then
            echo -e "Exit code: $ec, Could not connect to the server ${banks["$trimmed_server"]}($trimmed_server) on port $trimmed_port\n"
            echo -e "$trimmed_port\t----------\tCould not connect" >> $output
        fi
    done

    echo -e "\nPorts testing completed successfully for the ${banks["$trimmed_server"]}($trimmed_server), you can view the test result in the file $output\n\n"

    sleep 2s
done