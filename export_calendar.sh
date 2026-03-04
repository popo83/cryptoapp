#!/bin/bash
# Script per esportare eventi calendario + compleanni e inviare notifica

OUTPUT_FILE="$HOME/Documenti/openclaw/calendar_export.txt"
LOG_FILE="$HOME/Documenti/openclaw/calendar_cron.log"

echo "=== Eventi Calendario ===" > "$OUTPUT_FILE"
echo "Generato: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

EVENTS=$(osascript << 'EOF' 2>/dev/null
set outputText to ""
set startDate to (current date) - (1 * days)
set endDate to (current date) + (2 * days)

-- Eventi normali
tell application "Calendar"
    set calList to calendars
    repeat with cal in calList
        try
            set eventsList to events of cal whose start date > startDate and start date < endDate
            repeat with ev in eventsList
                set evTitle to summary of ev
                set evStart to start date of ev
                set evCal to name of cal
                set outputText to outputText & (evCal & " | " & evStart as string) & " | " & evTitle & "
"
            end repeat
        end try
    end repeat
end tell

return outputText
EOF
)

echo "$EVENTS" >> "$OUTPUT_FILE"

# Crea riassunto per Telegram
SUMMARY="📅 *Oggi e Domani*

"

# Oggi
TODAY=$(date +"%d %b")
SUMMARY+="*OGGI ($TODAY):*"

TODAY_EVENTS=$(echo "$EVENTS" | grep -i "$(date +%d)" | head -5)
if [ -n "$TODAY_EVENTS" ]; then
    SUMMARY+="
$TODAY_EVENTS"
else
    SUMMARY+=" Nessun evento
"
fi

# Domani
TOMORROW=$(date -v+1d +"%d %b" 2>/dev/null || date -d "+1 day" +"%d %b" 2>/dev/null)
SUMMARY+="

*DOMANI ($TOMORROW):*"

TOMORROW_EVENTS=$(echo "$EVENTS" | grep -i "$(date -v+1d +%d 2>/dev/null || date -d "+1 day" +%d 2>/dev/null)" | head -5)
if [ -n "$TOMORROW_EVENTS" ]; then
    SUMMARY+="
$TOMORROW_EVENTS"
else
    SUMMARY+=" Nessun evento
"
fi

# Invia a Telegram
openclaw message send --channel telegram --target 1075906736 --message "$SUMMARY" >> "$LOG_FILE" 2>&1

echo "Notifica inviata: $(date)" >> "$LOG_FILE"
