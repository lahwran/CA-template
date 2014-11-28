#!/usr/bin/python

import os
import sys
import re
import argparse

def servers_or_clients(val):
    if val not in ["servers", "clients"]:
        raise ValueError("Must be 'servers' or 'clients'")
    return val

parser = argparse.ArgumentParser()
parser.add_argument("kind", help="whether to generate for 'servers' or 'clients'",
        type=servers_or_clients)
parser.add_argument("filename", help="filename to put cert in")
parser.add_argument("sign_args", nargs=argparse.REMAINDER)
args = parser.parse_args()

directory = "certs/"
print os.listdir(directory)
pems = [x for x in os.listdir(directory) if re.match("^[0-9]+.pem$", x)]
pem_numbers = [int(x.partition(".")[0]) for x in pems] or [0]
next_number = max(pem_numbers) + 1
next_cert = str(next_number).rjust(2, "0")

print "Kind will be", repr(args.kind)
print "Filename will be", repr(args.filename)

if args.sign_args:
    print "These extra arguments will be passed to ./sign.sh:"
    for argument in args.sign_args:
        print "    " + repr(argument)
else:
    print "No extra arguments will be passed to sign.sh."

print "Files:"
print "    incoming/{}.csr".format(args.filename)
print "    incoming/{}.pem".format(args.filename)
print "    certs/{0}.pem".format(next_cert)
print "    output/{0}.key.pem (same file as incoming/{0}.pem)".format(args.filename)
print "    output/{0}.crt.pem (same file as certs/{1}.pem)".format(args.filename, next_cert)

answer = raw_input("Is all of the above OK? [y/n] ")

if answer.strip().lower() != "y":
    sys.exit(1)

print "Your provided name will *not* be used in the cert itself unless"
print "you provide it again in the following questions."

sys.exit(1)

subprocess.call([
    "openssl", "req",
    "-out", "incoming/{}.csr".format(args.filename),
    "-new", "-newkey", "rsa:4096", "-nodes",
    "-keyout", "incoming/{}.pem".format(args.filename)
])
subprocess.call([
    "./sign.sh",
    args.kind,
    "incoming/{}.csr".format(args.filename)
] + args.sign_args)

try:
    os.makedirs("output")
except OSError as e:
    if e.errno == 17:
        pass
    else:
        raise

os.link("incoming/{}.pem".format(args.filename),
        "output/{}.key.pem".format(args.filename))
os.link("certs/{}.pem".format(next_cert),
        "output/{}.crt.pem".format(args.filename))

print "done"
