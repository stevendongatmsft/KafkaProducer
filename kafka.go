package main

import (
	"crypto/tls"
	"fmt"
	"math/rand"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/Shopify/sarama"
)

var totalMsg int
var totalBurst int
var totalSendDur int
var totalRestDur int
var topic = getenv("TOPIC", "lessthan100partitions")
var brokers = getenv("BROKERS", "kafka-1.mh-lbnyvywmvwwvpcmssqgl-4c201a12d7add7c99d2b22e361c6f175-0000.us-south.containers.appdomain.cloud:9093")
var username = getenv("USERNAME", "token")
var password = getenv("PASSWORD", "")
var consumergroup = getenv("CONSUMERGROUP", "code-engin-test1")
var ratedeviation, _ = strconv.ParseInt(getenv("RATEDEVIATION", "20"), 10, 64)
var rate, _ = strconv.ParseInt(getenv("RATE", "500"), 10, 64)
var senddurationdeviation, _ = strconv.ParseInt(getenv("SENDDURATIONDEVIATION", "1"), 10, 64)
var sendduration, _ = strconv.ParseInt(getenv("SENDDURATION", "10"), 10, 64)
var restdurationdeviation, _ = strconv.ParseInt(getenv("RESTDURATIONDEVIATION", "0"), 10, 64)
var restduration, _ = strconv.ParseInt(getenv("RESTDURATION", "1"), 10, 64)
var msg = "sample message 1"

func main() {
	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		fmt.Println("Keyboard interrupted. Exit Program")
		fmt.Println("total produced messages: ", totalMsg)
		fmt.Println("average burst rate is: ", totalMsg/totalBurst)
		fmt.Println("average rest duration is: ", totalRestDur/totalBurst)
		fmt.Println("average send duration is: ", totalSendDur/totalBurst)
		os.Exit(1)
	}()

	go loopPrint()

	config, err := kafkaConfig()
	if err != nil {
		fmt.Println(err.Error())
	}
	producer, err := sarama.NewSyncProducer([]string{brokers}, config)
	if err != nil {
		fmt.Println(err.Error())
	}
	produce(int(rate), int(ratedeviation), int(restduration), int(restdurationdeviation), int(sendduration), int(senddurationdeviation), &producer)
}

func getenv(key, fallback string) string {
	value := os.Getenv(key)
	if len(value) == 0 {
		return fallback
	}
	return value
}

func produce(targetRate int, rateSpan int, targetRestDuration int, targetRestSpan int, targetSendDuration int, targetSendSpan int, p *sarama.SyncProducer) {
	rest := false
	for {
		if rest {
			ima := time.Now()
			if targetRestDuration != 0 {
				restDuration := generateRandomNum(targetRestSpan, targetRestDuration)
				time.Sleep(time.Duration(restDuration) * time.Second)
				fmt.Println("slept ", time.Since(ima), " seconds.")
				totalRestDur += restDuration
			}
			rest = false
		} else {
			produceMessage(targetRate, rateSpan, targetSendDuration, targetSendSpan, &rest, p)
		}
	}
}

func produceMessage(targetRate int, rateSpan int, targetSendDuration int, targetSendSpan int, rest *bool, p *sarama.SyncProducer) {
	totalBurst += 1
	rate, sendDuration := generateRandomNum(rateSpan, targetRate), generateRandomNum(targetSendSpan, targetSendDuration)
	totalSendDur += sendDuration
	start := time.Now()
	ticker := time.NewTicker(time.Duration(sendDuration) * time.Second)
	fmt.Println("will send for", sendDuration, "seconds.")
	stopped := false
	count := 0

	go func() {
		for {
			select {
			case <-ticker.C:
				stopped = true
				ticker.Stop()
				break
			}
			break
		}
	}()
	for {
		if stopped {
			fmt.Println("sent", count, "within", time.Since(start))
			*rest = true
			break
		}
		if count >= rate {
			continue
		}
		message := &sarama.ProducerMessage{
			Topic: topic,
			Value: sarama.StringEncoder(msg),
		}
		_, _, err := (*p).SendMessage(message)
		if err != nil {
			fmt.Println(err.Error())
			break
		}
		//fmt.Printf("Produced message to partition %d offset %d\n", partition, offset)
		count += 1
		totalMsg += 1
	}
}

func generateRandomNum(span int, targetRate int) int {
	if span == 0 {
		return targetRate
	}
	rand.Seed(time.Now().UnixNano())
	min := targetRate - span
	return rand.Intn((targetRate+span)-min) + min + 1
}

func loopPrint() {
	for {
		time.Sleep(10 * time.Second)
		fmt.Println("total Msg is: ", totalMsg)
		fmt.Println("average burst rate is: ", totalMsg/totalBurst)
		fmt.Println("average rest duration is: ", totalRestDur/totalBurst)
		fmt.Println("average send duration is: ", totalSendDur/totalBurst)
	}
}

func kafkaConfig() (kafkaConfig *sarama.Config, err error) {
	apiKey := password
	user := username
	kafkaVersion := "2.3.0"

	kafkaConfig = sarama.NewConfig()

	if kafkaConfig.Version, err = sarama.ParseKafkaVersion(kafkaVersion); err != nil {
		return nil, err
	}

	// Use OffsetOldest instead of OffsetOldest. This will pull any lingering
	// messages from the queue when the provider starts
	kafkaConfig.ClientID = consumergroup

	kafkaConfig.Producer.Partitioner = sarama.NewRoundRobinPartitioner
	kafkaConfig.Producer.RequiredAcks = sarama.WaitForLocal
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

func inClusterKafkaConfig() (kafkaConfig *sarama.Config, err error) {
	kafkaConfig = sarama.NewConfig()

	kafkaConfig.ClientID = "knative-e2e"

	kafkaConfig.Producer.Partitioner = sarama.NewRandomPartitioner
	kafkaConfig.Producer.RequiredAcks = sarama.WaitForAll
	kafkaConfig.Producer.Return.Successes = true

	return kafkaConfig, nil
}
