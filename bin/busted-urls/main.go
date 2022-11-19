package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"regexp"
	"strings"
)

const zoneID = "07b12080f7b57c1869b98fbceb028569"

var authKey, authEmail string

func init() {
	authKey = os.Getenv("CF_AUTH_KEY")
	if authKey == "" {
		fmt.Fprintln(os.Stderr, "set CF_AUTH_KEY (https://api.cloudflare.com/#getting-started-requests)")
		os.Exit(1)
	}
	authEmail = os.Getenv("CF_AUTH_EMAIL")
	if authEmail == "" {
		fmt.Fprintln(os.Stderr, "set CF_AUTH_EMAIL (https://api.cloudflare.com/#getting-started-requests)")
		os.Exit(1)
	}
}

func main() {
	pat := regexp.MustCompile(`'s3://(\S+)'`)
	a := make([]string, 0, 30)
	r := bufio.NewScanner(os.Stdin)
	for r.Scan() {
		f := pat.FindStringSubmatch(r.Text())
		if len(f) == 0 {
			continue
		}
		url := f[1]
		if strings.HasSuffix(url, "/index.html") {
			url = strings.TrimSuffix(url, "index.html")
		}

		a = append(a, "https://" + url)

		if len(a) == 30 {
			purge(a)
			a = a[:0]
		}
	}

	if len(a) > 0 {
		purge(a)
	}
}

func purge(a []string) {
	fmt.Fprintln(os.Stderr, "purging", a)

	var in struct {
		Files []string `json:"files"`
	}
	in.Files = a

	b, err := json.Marshal(in)
	if err != nil {
		panic("couldn't encode json: " + err.Error())
	}

	req, err := http.NewRequest(
		"POST", "https://api.cloudflare.com/client/v4/zones/"+zoneID+"/purge_cache",
		bytes.NewReader(b),
	)
	if err != nil {
		panic("couldn't create request: " + err.Error())
	}

	req.Header.Add("User-Agent", "foolish-cacheclear")
	req.Header.Add("Content-Type", "application/json")
	req.Header.Add("X-Auth-Key", authKey)
	req.Header.Add("X-Auth-Email", authEmail)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		fmt.Fprintf(os.Stderr, "couldn't bust cache: %s\n", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		fmt.Fprintln(os.Stderr, resp.Status)
		io.Copy(os.Stderr, resp.Body)
	}
}
