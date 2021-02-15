package main

import (
    "flag"
    "log"
    "time"
    "net/http"
    "os"
    "github.com/getsentry/sentry-go"
)


func main() {
    err := sentry.Init(sentry.ClientOptions{
        Dsn: os.Getenv("SENTRY_DSN"),
    })

    if err != nil {
        log.Fatalf("sentry.Init: %s", err)
    }

    defer sentry.Flush(2 * time.Second)

    addr := flag.String("addr", "0.0.0.0:8080", "http service address")
    flag.Parse()
    //log.SetFlags(0)
    http.HandleFunc("/relay", relay)

    go queueGroomer()
    log.Fatal(http.ListenAndServe(*addr, nil))
}
