# Caching

Currently caching is only available as a beta feature.


## Create new folder

`mkdir ksm-example-cache`{{execute}}

## Change directory

`cd ksm-example-cache`{{execute}}

## Initialize go module

`go mod init ksm-example-cache`{{execute}}

## Install the beta version of the SDK that includes caching

`go get github.com/keeper-security/secrets-manager-go/core@beta-caching`{{execute}}

## Create new code file:

`touch ksm-example-cache.go`{{execute}}

## Paste the following code into the file

```golang
package main

import (
	"fmt"
	"os"
	"strings"

	ksm "github.com/keeper-security/secrets-manager-go/core"
	klog "github.com/keeper-security/secrets-manager-go/core/logger"
)

// go get github.com/keeper-security/secrets-manager-go/core@beta-caching
// This PoC is currently available only in the beta-caching branch

func main() {
	// klog.SetLogLevel(klog.CriticalLevel) // == klog.SetLogLevel(io.Discard)
	klog.SetLogLevel(klog.DebugLevel)
	klog.Info("Secrets Manager Started")

	// PreferCache: false - by default
	options := &ksm.ClientOptions{
		// Config: ksm.NewFileKeyValueStorage("ksm-config.json"), // either use token or copy valid config here
		Config: ksm.NewMemoryKeyValueStorage("[KSM CONFIG BASE64]"), // read-only config
		PreferCache: true, // can be reset/revoked at runtime too: sm.PreferCache = true
	}

	sm := ksm.NewSecretsManager(options)

	// NB! Avoid using record filters with caching - cache keeps filtered records only!
	// ex. cache record UID1 use same cache with different filter to get UID2 gets empty result

	// NB! Cache keeps only last response from GetSecrets (updated by every GetSecrets call)
	// ex. GetSecrets([]string{}) ... GetSecrets([]string{"UID1"}) - UID1 only in cache

	// SetCache test
	sm.PreferCache = true                 // can be reset/revoked at runtime too
	_ = sm.SetCache(ksm.NewMemoryCache()) // no need to cache starting nil
	// built-in cache implementations: NewMemoryCache(), NewFileCache()
	recs, err := sm.GetSecrets([]string{"[RECORD UID 1]"})
	if err != nil {
		klog.Error("error retrieving records: " + err.Error())
	}
	fmt.Println(recs[0].Title())

	recs[0].SetTitle(recs[0].Title() + ".")
	sm.Save(recs[0]) // backend updates but not the local cache
	recs, err = sm.GetSecrets([]string{"[RECORD UID 1]"})
	fmt.Println(recs[0].Title(), err) // still old/cached title

	// time to update cache
	mc1 := sm.SetCache(ksm.NewMemoryCache())                      // new empty cache, but mc1 holds old cache
	recs, err = sm.GetSecrets([]string{"[RECORD UID 1]"}) // cache new/latest title
	fmt.Println(recs[0].Title(), err)                             // new title
	// record updates should succeed here (assuming no external vault modifications)

	sm.SetCache(mc1) // restore prev. cache
	recs, err = sm.GetSecrets([]string{"[RECORD UID 1]"})
	fmt.Println(recs[0].Title(), err) // old title
	// record update should fail here - cache keeps old record revision
	// Old cached rec will get Out-Of-Sync error due record revisions mismatch

	mc2 := sm.SetCache(nil)          // no caching (even if sm.PreferCache = true)
	cache, _ := mc2.GetCachedValue() // store in online or offline storage - memcache loads w/ SaveCachedValue
	fmt.Print(cache[:8])             // or
	recs, _ = sm.GetSecrets([]string{"[RECORD UID 1]"})
	recs[0].SetTitle(strings.TrimRight(recs[0].Title(), "."))
	sm.Save(recs[0]) // restore original title

	// If caching is disabled but cache is set it will still cache every/last GetSecrets
	// but will use cached data only if there's no network connectivity and backend is inaccessible
	// If there's no cache then failure to connect to the backend will result in an error
	sm.PreferCache = false
	// ~SetCache test

	// To minimize htis to the backend - retrieve all/unfiltered records shared to the KSM app
	allRecords, err := sm.GetSecrets([]string{})
	if err != nil {
		klog.Error("error retrieving all records: " + err.Error())
		os.Exit(1)
	}

	// main loop - branches out based on record's purpose
	for _, r := range allRecords {
		klog.Println("\tTitle: " + r.Title())
		// branch based on record contents
		// if r.Uid  == "UID1" || r.Title() == "database1" {...}
	}

	klog.Info("Secrets Manager Finished")
}

```{{copy}}

> Note: <br />
> - Replace `[RECORD UID 1]` with the UID of the record you want to use for testing. <br />
> - Replace `[KSM CONFIG BASE 64]` with the base64 encoded KSM config.

## Run Go Mod Tidy to find all referenced to the imported packages

`go mod tidy`{{execute}}

## Run application

`go run ksm-example-cache.go`{{execute}}
