#!/bin/bash
# Website access report for 4IN01D.com

LOG="/var/log/nginx/access.log"
TOTAL=$(wc -l < "$LOG")
UNIQUES=$(awk '{print $1}' "$LOG" | sort -u | wc -l)

echo "4IN01D.com Access Report - $(date)"
echo "=============================="
echo "Total accesses: $TOTAL"
echo "Unique visitors: $UNIQUES"
echo ""
echo "Top 5 IPs:"
awk '{print $1}' "$LOG" | sort | uniq -c | sort -rn | head -5
