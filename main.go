package main

import (
	"context"
	"fmt"
	"math/rand"
	"net/http"
	"os"
//	"strconv"
//	"strings"
	"github.com/jackc/pgx/v5/pgxpool"
	"time"
)

// Database variable
// var db *pgx.Conn
var db *pgxpool.Pool

/*
func saveStats() {
	content := fmt.Sprintf("%d,%d", totalSum, totalCount)
	os.WriteFile(statsFile, []byte(content), 0644)
}
*/

func handler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path == "/favicon.ico" {
		return
	}
	
	// Keep rolling rolling rolling rolling!
	d1, d2 := rand.Intn(6)+1, rand.Intn(6)+1
	
	// Save to DB
	_, err := db.Exec(r.Context(),
	"INSERT INTO rolls (die1, die2, dice_type) VALUES ($1, $2, $3)",
	d1, d2, "standard")

	if err != nil {
		fmt.Printf("Database errror: %v\n", err)
		}
	
	// Keep rolling rolling rolling a secret
	// Check to see if secret is unlocked
	secretUnlocked := r.URL.Query().Get("secret") == "snakeeyes"
	var s1, s2 int
	if secretUnlocked {
		s1, s2 = rand.Intn(6)+1, rand.Intn(6)+1
		_, err = db.Exec(r.Context(),
		"INSERT INTO rolls (die1, die2, dice_type) VALUES ($1, $2, $3)",
		s1, s2, "secret")
		}

	if err != nil {
		fmt.Printf("Database errror: %v\n", err)
		}

	
	var totalCount int
	var average float64
	var snakeEyes int
	var totalDoubles int

	err = db.QueryRow(context.Background(), `
		SELECT 
			COUNT(*), 
			COALESCE(AVG(die1 + die2), 0),
			COUNT(*) FILTER (WHERE die1 = 1 AND die2 = 1),
			COUNT(*) FILTER (WHERE die1 = die2)
		FROM rolls
	`).Scan(&totalCount, &average, &snakeEyes, &totalDoubles)

	if err != nil {
		fmt.Printf("Query errror: %v\n", err)
	}

	fmt.Fprintf(w, `
	<html>
        <body style="font-family:sans-serif; text-align:center; padding-top:50px; background-color:#f4f4f9; color:#333;">
            <h1>🎲 Da Daniel Double Dice Den</h1>
            
            <div style="background:white; width:60%%; margin:20px auto; padding:20px; border-radius:15px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                <p style="font-size:4em; margin: 10px 0;">%s %s</p>
                <p style="font-size:1.5em;">Standard Result: %d + %d = <strong>%d</strong></p>
                
                %s

                <br>
		<form action="/" method="GET" style="margin-top: 20px; border-top: 1px dashed #ccc; padding-top: 15px;">
    		<input type="text" name="secret" placeholder="Enter secret code..." style="padding: 10px; border-radius: 5px; border: 1px solid #ccc;">
		<button type="submit" style="padding: 10px 20px; cursor: pointer; background-color: #555; color: white; border: none; border-radius: 5px;">Unlock</button>
		</form>
		
                <button onclick="location.reload()" style="padding:15px 30px; font-size:1.2em; cursor:pointer; background-color:#4CAF50; color:white; border:none; border-radius:5px; margin-top:20px;">Roll Again</button>
            </div>
            
            <hr style="width:60%%; margin:40px auto; border: 0; border-top: 1px solid #ccc;">
            
            <div style="display:flex; justify-content:center; gap:50px;">
                <div><h3 style="color:#666;">Total Rolls</h3><p style="font-size:2em; font-weight:bold;">%d</p></div>
                <div><h3 style="color:#666;">Average</h3><p style="font-size:2em; font-weight:bold;">%.2f</p></div>
                <div><h3 style="color:#666;">Snake Eyes 🐍</h3><p style="font-size:2em; font-weight:bold;">%d</p></div>
		<div><h3 style="color:#666:">Total Doubles ✨</h3><p style="font-size:2em; font-weight:bold;">%d</p></div>
            </div>
        </body>
    </html>
    `,
    getDiceIcon(d1), getDiceIcon(d2), d1, d2, d1+d2, 
    func() string { 
        if secretUnlocked { 
            return fmt.Sprintf("<hr><p style='font-size:3em; margin:10px 0;'>%s %s</p><p style='color:purple; font-size:1.2em;'>Secret: %d + %d = %d</p>", 
                getDiceIcon(s1), getDiceIcon(s2), s1, s2, s1+s2) 
        }
        return "" 
    }(),
    totalCount, average, snakeEyes, totalDoubles)
	
}

func getDiceIcon(n int) string {
	icons := map[int]string{
		1: "⚀", 2: "⚁", 3: "⚂", 4: "⚃", 5: "⚄", 6: "⚅",
	}
	return icons[n]
}

func main() {
	// Get connection string from environment variable (docker-compose)
	connStr := os.Getenv("DATABASE_URL")
	if connStr == "" {
		// Fallback to local
		connStr = "postgres://daniel:dicepassword@localhost:5432/dicedb"
		}
	
	// Connect to database
	var err error
	
	// Time loop to pause for database initialisation
	for i :=0; i < 10; i++ {
		db, err = pgxpool.New(context.Background(), connStr)
		if err == nil {
			err = db.Ping(context.Background())
			if err == nil {
				fmt.Println("Successfully connected to database")
				break
				}
			}
		fmt.Printf("Database not ready yet (attempt %d/10). Waiting 2 seconds.\n", i+1)
		time.Sleep(2*time.Second)
		}
	
	
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to connect to database after 10 attempts: %v\n", err)
		os.Exit(1)
		}
	defer db.Close()
	
	// Create the table if not exist (simple migration)
	query := `CREATE TABLE IF NOT EXISTS rolls (
		id SERIAL PRIMARY KEY,
		die1 INTEGER,
		die2 INTEGER,
		dice_type TEXT DEFAULT 'standard',
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		);`
	_, err = db.Exec(context.Background(), query)
	if err != nil {
		fmt.Printf("Error creating table: %v\n", err)
		}
		
	// Start web server
	http.HandleFunc("/", handler)
	fmt.Println("Server starting on port 80...")
	// Port 80 for HTTP
	if err := http.ListenAndServe(":80", nil); err != nil {
		fmt.Printf("Error: %s. Contact administrator.\n", err)
	}
}
