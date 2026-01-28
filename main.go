package main

import (
	"fmt"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"strings"
)

const statsFile = "totals.txt"

var totalSum int
var totalCount int

// Load stats from file
func init() {
	data, err := os.ReadFile(statsFile)
	if err == nil {
		parts := strings.Split(string(data), ",")
		if len(parts) == 2 {
			totalSum, _ = strconv.Atoi(parts[0])
			totalCount, _ = strconv.Atoi(parts[1])
		}
	}
}

func saveStats() {
	content := fmt.Sprintf("%d,%d", totalSum, totalCount)
	os.WriteFile(statsFile, []byte(content), 0644)
}

func handler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path == "/favicon.ico" {
		return
	}
	d1, d2 := rand.Intn(6)+1, rand.Intn(6)+1
	current := d1 + d2

	totalSum += current
	totalCount++
	saveStats()

	avg := float64(totalSum) / float64(totalCount)

	// HTML Output
	fmt.Fprintf(w, `
                <html>
                        <body style="font-family:sans-serif; text-align:center; padding-top:50px;">
                                <h1>🎲 Da Daniel Double Dice Roller</h1>
                                <p style="font-size:2em;">Result: %d + %d = <strong>%d</strong></p>
                                <hr style="width:50%%">
                                <p>Total Rolls: %d | Average: <strong>%.4f</strong></p>
                                <button onclick="location.reload()" style="padding:10px 20px; font-size:1em; cursor:pointer;">Roll Again</button>
                        </body>
                </html>
        `, d1, d2, current, totalCount, avg)
}

func main() {
	http.HandleFunc("/", handler)
	fmt.Println("Server starting on port 80...")
	// Port 80 for HTTP
	if err := http.ListenAndServe(":80", nil); err != nil {
		fmt.Printf("Error: %s. (Try running with 'sudo')\n", err)
	}
}
