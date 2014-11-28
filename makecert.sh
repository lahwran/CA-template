#!/bin/bash

NEXT_NUMBER="$(@ 'str(1 + max(int(x.partition(".")[0]) for x in os.listdir(directory) if re.match("^[0-9]+.pem$", x))).rjust(2, "0")' -v directory=certs/)"

KIND="$1"
if [ "$KIND" != "servers" ] && [ "$KIND" != "clients" ]; then
    echo "Kind must be one of 'servers' or 'clients', not '${KIND}'"
    exit 1
fi

echo "Kind will be '${KIND}'"

shift

NAME="$1"
echo "Name will be '${NAME}'"
shift

if [ "$*" != "" ]; then
    echo "These extra arguments will be passed to ./sign.sh:"
    for argument in "$@"; do
        echo -Een "    $argument\n"
    done
else
    echo "No extra arguments will be passed to sign.sh."
fi

echo "Files:"
echo "    incoming/${NAME}.csr"
echo "    incoming/${NAME}.pem"
echo "    certs/${NEXT_NUMBER}.pem"
echo "    output/${NAME}.key.pem (same file as incoming/${NAME}.pem)"
echo "    output/${NAME}.crt.pem (same file as certs/${NEXT_NUMBER}.pem)"

echo -n "Is all of the above OK? [y/n] "

read answer
if [ "$answer" != "y" ]; then
    exit 1
fi

echo "Your provided name will *not* be used in the cert itself unless"
echo "you provide it again in the following questions."

openssl req -out "incoming/${NAME}.csr" -new -newkey rsa:4096 -nodes -keyout "incoming/${NAME}.pem"
./sign.sh "$KIND" "incoming/${NAME}.csr"

mkdir -p output
ln "incoming/${NAME}.pem" "output/${NAME}.key.pem"
ln "certs/${NEXT_NUMBER}.pem" "output/${NAME}.crt.pem"

echo "done"
