#!/usr/bin/env bash

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found!"
    exit 1
fi

echo "Cleaning out the Dice Den..."
docker-compose exec db psql -U "$DB_USER" -d "$DB_NAME" -c "TRUNCATE TABLE rolls;"

echo "Database cleared. Ready for more losers!"