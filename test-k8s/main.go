/**
 * Writing tests of Kubernetes infrastructure with the Go K8s client library.
 * Author: Andrew Jarombek
 * Date: 7/3/2020
 */

package main

import (
	"flag"
	"fmt"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
)

func main() {
	var kubeconfig *string = flag.String("kubeconfig", "", "Absolute path to the kubeconfig file.")
	flag.Parse()

	config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)

	if err != nil {
		panic(err.Error())
	}

	clientset, err := kubernetes.NewForConfig(config)

	if err != nil {
		panic(err.Error())
	}

	pods, err := clientset.CoreV1().Pods("").List(metav1.ListOptions{})

	if err != nil {
		panic(err.Error())
	}

	fmt.Printf("There are %d pods in the cluster.\n", len(pods.Items))
	fmt.Printf("%d", pods.Items[0].String())
}