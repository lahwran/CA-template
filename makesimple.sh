#!/bin/bash

if ! [ -e output/ca.crt.pem ]; then
    echo "**************************************"
    echo "          Setting up CA..."
    echo "**************************************"
    ./init.sh
fi

if ! [ -e output/server.crt.pem ]; then
    echo "**************************************"
    echo "      Generating server cert..."
    echo "**************************************"
    ./makecert.py servers server
fi

if ! [ -e output/client.crt.pem ]; then
    echo "**************************************"
    echo "      Generating client cert..."
    echo "**************************************"
    ./makecert.py clients client
fi
