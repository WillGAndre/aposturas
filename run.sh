#!/bin/bash

show_help() {
    echo "Usage: $0 [encrypt|decrypt]"
}
if [ "$1" != "encrypt" ] && [ "$1" != "decrypt" ]; then
    show_help
    exit 1
fi
(read -s -p "Password: " PASSWORD && export PASSWORD && make $1 && unset PASSWORD)