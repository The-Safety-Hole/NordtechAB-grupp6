#!/bin/bash
sudo systemctl stop dice
sudo systemctl disable dice
docker build -t dice-app:latest .
docker run -d -p 80:80 --name dice-container -v $(pwd)/totals.txt:/root/totals.txt --restart always dice-app:latest
