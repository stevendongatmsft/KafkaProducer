#!/bin/bash

set +x
set -e

send() {
    TOPIC=my-topic EVENTCT=3 BROKERS="my-cluster-kafka-bootstrap:9092" PASSWORD="" go run kafka.go
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