# DA DANIEL DOUBLE DICE DEN
### A secure and amazingly fun containerized Go application

Just kidding. This is a pointless app that simulates dice rolling.
You get two D6 dice. Click the button to roll them. It's not difficult.

### Features
-- Three-tier architecture: Nginx (proxy), Go (app), PostgreSQL (database).
-- Persistent stats: Tracks total rolls, averages, snake eyes (double 1) and total doubles.
-- Rate limiting: Nginx-level protection to prevent spam and DDoS. Also sometimes disables the database.
-- GDPR-compliant logging: Automatic IP logging for security and spam protection with short term log rotation and a 3 file retention policy.

### Tech Stack
-- Language: Go (Golang)
-- Database: PostgreSQL
-- Proxy: Nginx
-- Environment: Docker and Docker Compose

### Installation
1. Clone the repository:
    `git clone https://github.com/yourusername/dice-den.git`
2. Environment variables:
    Create a `.env` file with the following:
        ```
        DB_USER=
        DB_PASSWORD=
        DB_NAME=
        ```
    Then fill in the blanks to your liking.
3. Run it:
    `docker-compose up -d --build`
4. Troubleshoot:
    Something is bound to go wrong. It's your problem now.
    
### Security and privacy
GDPR: Logging is for reasons of security and troubleshooting. Logs are not shared. Logs are rotated and old logs are permanently deleted in short intervals.

Rate limiting: Nginx really doesn't like it if you make more than two rolls per second. But it's sketchy so sometimes doesn't work. Don't abuse it please.

