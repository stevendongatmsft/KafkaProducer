#!/bin/bash

set +x
set -e

send() {
    TOPIC=p100 EVENTCT=1 BROKERS="broker-1-6h9cxrv6h456kwnb.kafka.svc10.us-south.eventstreams.cloud.ibm.com:9093" PASSWORD="" go run kafka.go
}

callingfunc=$1


run () {
    if [ $callingfunc = "send" ]; then
        echo "sending events"
        send
    else 
        echo "check your argument(s)"
    fi
    
}


run 