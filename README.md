# KafkaProducer

Clone this repo and run 
```
chmod +x send.sh
```

To send events to your indicated topic, make sure you replace the variables in your send.sh script: 

TOPIC=p100 EVENTCT=1 BROKERS="" PASSWORD="" go run kafka.go

TOPIC is the topic you want events to be sent to 
EVENTCT represents the event count you want to send 
BROKERS is the broker addresses 
PASSWORD is the apikey or password you use to access your Kafka instance 


Then run 
```
./send.sh send

```
