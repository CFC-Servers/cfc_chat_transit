package main

import (
	"flag"
	"log"
	"net/http"
)

func main() {
	addr := flag.String("addr", "0.0.0.0:8080", "http service address")
	flag.Parse()
	//log.SetFlags(0)
	http.HandleFunc("/relay", relay)

	go queueGroomer()
	log.Fatal(http.ListenAndServe(*addr, nil))
}
