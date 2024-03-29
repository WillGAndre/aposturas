#!/bin/bash

(read -s -p "Password: " PASSWORD && export PASSWORD && make decrypt && unset PASSWORD)