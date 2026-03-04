#!/bin/bash
# Website access report for 4IN01D.com - sends to Telegram

LOG="/var/log/nginx/access.log"
TOKEN="8632193057:AAGPCOA8xYTO2q4QMYNTST6kRkoCZhTQdlM"
CHAT_ID="1075906736"

TOTAL=$(wc -l < "$LOG")
UNIQUES=$(awk '{print $1}' "$LOG" | sort -u | wc -l)

MESSAGE="📊 4IN01D.com Stats%n%n👥 Visitatori: $UNIQUES%n📈 Accessi: $TOTAL"

# Send to Telegram
curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
  -d "chat_id=$CHAT_ID" \
  -d "text=$MESSAGE" > /dev/null 2>&1

# Also log
echo "$(date): Sent report - $UNIQUES visitors, $TOTAL accesses" >> /var/log/site_stats.log
