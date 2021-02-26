package main

import (
	"crypto/tls"
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/Shopify/sarama"
)

func main() {
	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		fmt.Println("Keyboard interrupted. Exit Program")
		os.Exit(1)
	}()

	config, err := inClusterKafkaConfig()
	if err != nil {
		fmt.Println(err.Error())
	}
	//brokers := []string{"broker-4-bqcn9zgxd1t3s58q.kafka.svc05.us-south.eventstreams.cloud.ibm.com:9093"}
	brokers := []string{"my-cluster-kafka-bootstrap.kafka:9092"}
	producer, err := sarama.NewSyncProducer(brokers, config)
	if err != nil {
		fmt.Println(err.Error())
	}

	//topic := "kafka-java-console-sample-topic"
	topic := "knative-demo-topic"
	msg := "actual information to save on kafka" //e.g {"name":"John Doe", "email":"john.doe@email.com"}

	for {
		message := &sarama.ProducerMessage{
			Topic: topic,
			Value: sarama.StringEncoder(msg),
		}
		partition, offset, err := producer.SendMessage(message)
		time.Sleep(1 * time.Millisecond)
		if err != nil {
			fmt.Println(err.Error())
			break
		}
		fmt.Printf("Produced message to partition %d offset %d\n", partition, offset)
	}
}

func inClusterKafkaConfig() (kafkaConfig *sarama.Config, err error) {
	kafkaConfig = sarama.NewConfig()

	kafkaConfig.ClientID = "knative-e2e"

	kafkaConfig.Producer.Partitioner = sarama.NewRandomPartitioner
	kafkaConfig.Producer.RequiredAcks = sarama.WaitForAll
	kafkaConfig.Producer.Return.Successes = true

	return kafkaConfig, nil
}

func kafkaConfig() (kafkaConfig *sarama.Config, err error) {
	apiKey := "DnfX7U4Z404roVsKYFWpRsRRJgScSofUIqCH01OHqtuF"
	user := "token"
	kafkaVersion := "2.3.0"

	kafkaConfig = sarama.NewConfig()

	if kafkaConfig.Version, err = sarama.ParseKafkaVersion(kafkaVersion); err != nil {
		return nil, err
	}

	// Use OffsetOldest instead of OffsetOldest. This will pull any lingering
	// messages from the queue when the provider starts
	kafkaConfig.ClientID = "knative-e2e"

	kafkaConfig.Producer.Partitioner = sarama.NewRandomPartitioner
	kafkaConfig.Producer.RequiredAcks = sarama.WaitForAll
	kafkaConfig.Producer.Return.Successes = true
	kafkaConfig.Net.SASL.Enable = true
	kafkaConfig.Net.SASL.Mechanism = sarama.SASLTypePlaintext
	kafkaConfig.Net.TLS.Enable = true
	kafkaConfig.Net.TLS.Config = &tls.Config{
		MinVersion:               tls.VersionTLS12,
		MaxVersion:               tls.VersionTLS12,
		PreferServerCipherSuites: true,
	}
	kafkaConfig.Net.SASL.User = user
	kafkaConfig.Net.SASL.Password = apiKey

	return kafkaConfig, nil
}
