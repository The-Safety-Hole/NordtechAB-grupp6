# Väljer Linux
FROM golang:1.23-alpine AS builder
# Arbetsmapp
WORKDIR /app
COPY . .
# Bygger
RUN go build -o dice-app .
# Byter arbetsmapp
FROM alpine:latest
WORKDIR /root/
# Kopiera lite skit
COPY --from=builder /app/dice-app .
# Se till att totals.txt finns
RUN touch totals.txt
# Öppna port 80
EXPOSE 80
# Kör app
CMD ["./dice-app"]
