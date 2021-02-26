#!/bin/bash

set +x
set -e

ls () {
    bx logout; 
    bx login --sso -a https://test.cloud.ibm.com -r eu-gb -g Default --apikey ***; 
    bx ce proj target -n newproj;
    bx ce proj current;

    export KUBECONFIG="/Users/steven.dong/.bluemix/plugins/code-engine/newproj-c7cfede3-70de-4d5d-9abf-d44c1301f9d1.yaml"
}

la() {
    bx logout; 
    bx login --sso -a https://cloud.ibm.com -c 175b993c36534af6be7a6499ce289d90 -r us-south
    bx ks cluster config -c dev-pg1-s01


}


run() {
    ls
}

run