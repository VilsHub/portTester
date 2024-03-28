#!/bin/bash

#Call using the format scriptName -p portsFile

# _________________Functions definitions starts_____________
function fileExist (){

    file=$1

    if [ ! -f $file ]; then
        echo -e "The file '$file' does not exist, please confirm and try again\n"
        exit 2
    fi

}
function start_listener() {
  port=$1
  nc -l -p $port &
  echo "Listening on port $port"
}
# _________________Functions definitions ends_______________

portFile=""
while getopts "p:" variable; do
case "$variable" in
    p)
        portFile=$OPTARG
        fileExist $portFile
    ;;
esac
done


# Check if the port file has been specified
if [ -z $portFile ]; then
    echo -e "Please specify the portFile, using '-p' option, and try again\n"
    exit 2
fi

readarray -t ports < $portFile


for port in "${ports[@]}"; do
  # Parse Data
  trimmed_port=$(echo $port | sed 's/[^0-9]//g')
  start_listener $trimmed_port
done

echo "Press Ctrl+C to stop all listeners"
trap "kill 0" EXIT
wait
