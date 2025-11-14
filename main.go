// main.go
package main

import (
	"fmt"
	"log"
	"net/http"
	"time"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
	// Get the current time in Málaga
	location, err := time.LoadLocation("Europe/Madrid")
	if err != nil {
		location = time.UTC
	}
	currentTime := time.Now().In(location).Format("15:04:05")

	// Write a response to the client
	fmt.Fprintf(w, "Hello, Kubernetes from Go! 🚀\n")
	fmt.Fprintf(w, "The current time is: %s\n", currentTime)
}

func main() {
	// Register the handler function for the "/" route
	http.HandleFunc("/", helloHandler)

	// Start the web server on port 8080
	fmt.Println("Server is listening on port 8080...")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
