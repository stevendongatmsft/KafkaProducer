#!/bin/bash

set +x
set -e

logIntoPg1 () {
    bx logout; 
    bx login --sso -a https://test.cloud.ibm.com -r eu-gb -g Default --apikey "VYTSHfGI5N6-ORAwgG2jE-T-iTJoISh90g-V4DKcN6is"; 
    bx ce proj target -n tuesday;
    kubefilewithgiberish=$(bx ce proj current | grep "Environment Variable:")
    kubefile=$(echo $kubefilewithgiberish | cut -d':' -f 2)
    echo $kubefile
    eval $kubefile
}

logIntoStage() {
    bx logout; 
    bx login --sso -a https://test.cloud.ibm.com -r us-south -g Default -c 80acffd55db6447c988599c09cabfb50
    bx ce proj target -n daniel-test;
    kubefilewithgiberish=$(bx ce proj current | grep "Environment Variable:")
    kubefile=$(echo $kubefilewithgiberish | cut -d':' -f 2)
    echo $kubefile
    eval $kubefile
}

la() {
    bx logout; 
    bx login --sso -a https://cloud.ibm.com -c 175b993c36534af6be7a6499ce289d90 -r us-south
    bx ks cluster config -c dev-pg1-s01
}

test() {
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/p300.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/p500.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/pa30.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/pa50.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/pa1.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/pa5.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/pa20.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/pa60.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/p100.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/e2e.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/ta4.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/ta6.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/ta9.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/ta10.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/ta15.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/ta7.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/ta20.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/tas1.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/ta12.yaml"
    kubectl apply -f "/Users/steven.dong/go/src/github.com/steven0711dong/KafkaProducer/test/ta2.yaml"
}

send() {
    TOPIC=p300 EVENTCT=500000 go run kafka.go
    TOPIC=p500 EVENTCT=100000 go run kafka.go
    TOPIC=pa30 EVENTCT=2000 go run kafka.go
    TOPIC=pa50 EVENTCT=2000 go run kafka.go
    TOPIC=pa1 EVENTCT=80 go run kafka.go
    TOPIC=pa5 EVENTCT=800 go run kafka.go
    TOPIC=pa20 EVENTCT=2000 go run kafka.go
    TOPIC=pa60 EVENTCT=10000 go run kafka.go
    TOPIC=dgrist100 EVENTCT=100000 go run kafka.go
    TOPIC=p100 EVENTCT=200000 BROKERS="broker-1-6h9cxrv6h456kwnb.kafka.svc10.us-south.eventstreams.cloud.ibm.com:9093" PASSWORD="d_kn114yXgyod742_iAinLUweuyT2EMC9g4z-2bce8Xb" go run kafka.go
    TOPIC=ta4 EVENTCT=1200 BROKERS="broker-4-7z8mjljpht52f0z8.kafka.svc07.us-south.eventstreams.cloud.ibm.com:9093" PASSWORD="zsajVwK2aGK0xHbqmKmmQRq_DDkq5ZMx3N6DBscP4fBF" go run kafka.go
    TOPIC=ta6 EVENTCT=100 BROKERS="broker-4-7z8mjljpht52f0z8.kafka.svc07.us-south.eventstreams.cloud.ibm.com:9093" PASSWORD="zsajVwK2aGK0xHbqmKmmQRq_DDkq5ZMx3N6DBscP4fBF" go run kafka.go
    TOPIC=ta9 EVENTCT=1000 BROKERS="broker-4-7z8mjljpht52f0z8.kafka.svc07.us-south.eventstreams.cloud.ibm.com:9093" PASSWORD="zsajVwK2aGK0xHbqmKmmQRq_DDkq5ZMx3N6DBscP4fBF" go run kafka.go
    TOPIC=ta10 EVENTCT=10000 BROKERS="broker-4-7z8mjljpht52f0z8.kafka.svc07.us-south.eventstreams.cloud.ibm.com:9093" PASSWORD="zsajVwK2aGK0xHbqmKmmQRq_DDkq5ZMx3N6DBscP4fBF" go run kafka.go
    TOPIC=ta15 EVENTCT=2000 BROKERS="broker-4-7z8mjljpht52f0z8.kafka.svc07.us-south.eventstreams.cloud.ibm.com:9093" PASSWORD="zsajVwK2aGK0xHbqmKmmQRq_DDkq5ZMx3N6DBscP4fBF" go run kafka.go
    TOPIC=ta7 EVENTCT=600 BROKERS="broker-4-7z8mjljpht52f0z8.kafka.svc07.us-south.eventstreams.cloud.ibm.com:9093" PASSWORD="zsajVwK2aGK0xHbqmKmmQRq_DDkq5ZMx3N6DBscP4fBF" go run kafka.go
    TOPIC=ta20 EVENTCT=1000 BROKERS="broker-4-7z8mjljpht52f0z8.kafka.svc07.us-south.eventstreams.cloud.ibm.com:9093" PASSWORD="zsajVwK2aGK0xHbqmKmmQRq_DDkq5ZMx3N6DBscP4fBF" go run kafka.go
    TOPIC=tas1 EVENTCT=4000 BROKERS="broker-4-7z8mjljpht52f0z8.kafka.svc07.us-south.eventstreams.cloud.ibm.com:9093" PASSWORD="zsajVwK2aGK0xHbqmKmmQRq_DDkq5ZMx3N6DBscP4fBF" go run kafka.go
    TOPIC=ta12 EVENTCT=600 BROKERS="broker-4-7z8mjljpht52f0z8.kafka.svc07.us-south.eventstreams.cloud.ibm.com:9093" PASSWORD="zsajVwK2aGK0xHbqmKmmQRq_DDkq5ZMx3N6DBscP4fBF" go run kafka.go
    TOPIC=ta2 EVENTCT=100 BROKERS="broker-4-7z8mjljpht52f0z8.kafka.svc07.us-south.eventstreams.cloud.ibm.com:9093" PASSWORD="zsajVwK2aGK0xHbqmKmmQRq_DDkq5ZMx3N6DBscP4fBF" go run kafka.go
}

clean() {
    kubectl delete kafkasource p300
    kubectl delete kafkasource p500
    kubectl delete kafkasource pa50
    kubectl delete kafkasource pa30
    kubectl delete kafkasource pa1
    kubectl delete kafkasource pa5
    kubectl delete kafkasource pa20
    kubectl delete kafkasource pa60
    kubectl delete kafkasource dgrist100
    kubectl delete kafkasource temp100
    kubectl delete kafkasource ta4
    kubectl delete kafkasource ta6
    kubectl delete kafkasource ta9
    kubectl delete kafkasource ta10
    kubectl delete kafkasource ta15
    kubectl delete kafkasource ta7
    kubectl delete kafkasource ta20
    kubectl delete kafkasource tas1
    kubectl delete kafkasource ta12
    kubectl delete kafkasource ta2
}

createTest() {
    bx ce app delete -f -n kafkasink || true 
    bx ce app delete -f -n scraper || true
    bx ce sub kafka delete -f -n $kafkasource || true 
    secretname=$topic-secret
    bx ce secret delete -f -n $secretname || true
    sleep 10
    bx ce secret create -n $secretname --from-literal=username=token --from-literal=password=$password
    scraperAddress=$(bx ce app create -n scraper -i stevendongatibm/scraper:1 --min 1 --max 1 | grep "//scraper")
    bx ce app create -n kafkasink -i stevendongatibm/event-display:1 --env cloudevent=false --env forward=true --env delay=$delaysecond --env scraper=$scraperAddress --env displayConcurrentConnections=true 
    cg=stevendong$topic
    bx ce sub kafka create -n $kafkasource -d kafkasink --consumer-group $cg --topic $topic --secret $secretname --broker $broker 
    TOPIC=$topic EVENTCT=$numofevents BROKERS=$broker PASSWORD=$password go run kafka.go
    scraperAddress=$scraperAddress/stats
    echo "Scraper address: $scraperAddress"
}



callingfunc=$1
delaysecond=$2 
numofevents=$3 
kafkasource=$4 
password=$5 
topic=$6 
broker=$7 



run () {
    if [ $callingfunc = "pg1" ]; then
        echo "Login into PG1"
        logIntoPg1
    elif [ $callingfunc = "pg1testonly" ]; then
        echo "Create test directly"
        createTest 
    elif [ $callingfunc = "pg1test" ]; then
        echo "Login into PG1"
        logIntoPg1
        echo "Create test directly"
        createTest
    elif [ $callingfunc = "stage" ]; then
        echo "Login into Stage"
        logIntoStage
    elif [ $callingfunc = "stagetestonly" ]; then
        echo "Create test directly"
        createTest 
    elif [ $callingfunc = "stagetest" ]; then
        echo "Login into Stage"
        logIntoStage
        echo "Create test directly"
        createTest
    else 
        echo "check your argument(s)"
    fi
    
}


run 