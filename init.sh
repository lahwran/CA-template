#!/bin/sh
set -eu

echo
echo ' *** Make sure to leave the challenge password empty! ***'
echo

mkdir -p incoming
openssl req -nodes -new -newkey rsa:4096 -keyout ca.key.pem -out incoming/ca.csr.pem
OPENSSL_CONF=ca.cnf openssl ca -selfsign -policy policy_ca -extensions ext_ca -in incoming/ca.csr.pem -out ca.crt.pem

mkdir -p output
ln certs/01.pem output/ca.crt.pem
