#!/usr/bin/env python3
import requests
import time
from datetime import datetime

SYMBOL = "BTCUSDT"
ENTRY_PRICE = 66500
STOP_LOSS = 60000
TAKE_PROFIT = 75000
CHECK_INTERVAL = 60

# Telegram config
TELEGRAM_TOKEN = "8632193057:AAGPCOA8xYTO2q4QMYNTST6kRkoCZhTQdlM"
TELEGRAM_CHAT_ID = "1075906736"

def send_telegram(message):
    url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
    data = {"chat_id": TELEGRAM_CHAT_ID, "text": message}
    try:
        requests.post(url, data=data)
    except Exception as e:
        print(f"Telegram error: {e}")

def get_price():
    url = f"https://api.binance.com/api/v3/ticker/price?symbol={SYMBOL}"
    r = requests.get(url)
    return float(r.json()["price"])

def check_position():
    price = get_price()
    now = datetime.now().strftime("%H:%M:%S")
    
    pl_percent = ((price - ENTRY_PRICE) / ENTRY_PRICE) * 100
    
    print(f"[{now}] BTC: ${price:.2f} | P/L: {pl_percent:+.2f}%")
    
    if price <= STOP_LOSS:
        msg = f"⚠️ STOP LOSS! BTC: ${price}"
        print(msg)
        send_telegram(msg)
        return "STOP"
    
    if price >= TAKE_PROFIT:
        msg = f"🎯 TAKE PROFIT! BTC: ${price}"
        print(msg)
        send_telegram(msg)
        return "PROFIT"
    
    return "HOLD"

print("Trading Bot started!")
print(f"Entry: ${ENTRY_PRICE} | Stop: ${STOP_LOSS} | Target: ${TAKE_PROFIT}")
send_telegram("🤖 Trading Bot avviato sulla VPS!")

while True:
    try:
        result = check_position()
    except Exception as e:
        print(f"Error: {e}")
    time.sleep(CHECK_INTERVAL)
