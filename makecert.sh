#!/bin/bash

openssl req -out incoming/$1.csr -new -newkey rsa:4096 -nodes -keyout incoming/$1.pem
