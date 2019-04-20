package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "OK")
}

func main() {
	http.HandleFunc("/", handler)
	port := os.Getenv("PORT")
	log.Printf("Listening on HTTP port %s", port)
	http.ListenAndServe(fmt.Sprintf(":%s", port), nil)
}
