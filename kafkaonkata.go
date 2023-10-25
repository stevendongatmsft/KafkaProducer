package main

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/Shopify/sarama"
)

func x() {

	producerConfig := sarama.NewConfig()
	producerConfig.ClientID = "kafka-on-kata-cc-mariner"

	//kafkaConfig.Producer.Partitioner = sarama.NewManualPartitioner
	producerConfig.Producer.RequiredAcks = sarama.WaitForLocal
	producerConfig.Producer.Return.Successes = true
	producer, err := sarama.NewAsyncProducer([]string{"my-cluster-kafka-bootstrap:9092"}, producerConfig)
	if err != nil {
		log.Printf("Error creating the Sarama sync producer: %v", err)
		os.Exit(1)
	}
	defer func() {
		err := producer.Close()
		if err != nil {
			fmt.Println("Error closing producer: ", err)
			return
		}
		fmt.Println("Producer closed")
	}()

	for {

		value := fmt.Sprintf("Message-%d", 0)
		message := sarama.ProducerMessage{Topic: topic, Value: sarama.StringEncoder(value)}

		select {
		case producer.Input() <- &message:
			fmt.Println("produced messages...")
		case err := <-producer.Errors():
			fmt.Println("Failed to produce message", err)
		case success := <-producer.Successes():
			fmt.Printf("Sent message value='%s' at partition = %d, offset = %d\n", success.Value, success.Partition, success.Offset)
		default:
			time.Sleep(time.Duration(0) * time.Millisecond)
		}
	}
}
