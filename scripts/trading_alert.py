#!/usr/bin/env python3
"""
Trading Alert Script - monitors crypto prices and notifies via Telegram
"""

import requests
import time
from datetime import datetime

# Configuration
TELEGRAM_CHAT_ID = "1075906736"
CHECK_INTERVAL = 60 * 60  # 1 hour

# Price alerts (symbol: threshold)
ALERTS = {
    "BTC": 50000,  # Alert if BTC < $50,000
    "ETH": 3000,   # Alert if ETH < $3,000
    "SOL": 100,    # Alert if SOL < $100
}

def send_telegram(message):
    """Send alert to Telegram"""
    try:
        script = f'''tell application "Messages" to send "{message}" to buddy id "{TELEGRAM_CHAT_ID}"'''
        import subprocess
        subprocess.run(["osascript", "-e", script], timeout=30, capture_output=True)
        print(f"📱 Notifica inviata!")
        return True
    except Exception as e:
        print(f"Errore Telegram: {e}")
        return False

def get_price(symbol):
    """Get crypto price from Binance API (free, no key needed)"""
    try:
        # Map common symbols to Binance symbols
        symbols_map = {"BTC": "btcusdt", "ETH": "ethusdt", "SOL": "solusdt"}
        binance_symbol = symbols_map.get(symbol.upper(), f"{symbol.lower()}usdt")
        
        url = f"https://api.binance.com/api/v3/ticker/price?symbol={binance_symbol.upper()}"
        resp = requests.get(url, timeout=10)
        
        if resp.status_code != 200:
            # Try with different endpoint
            url = f"https://api.binance.com/api/v3/ticker/24hr?symbol={binance_symbol.upper()}"
            resp = requests.get(url, timeout=10)
            
        if resp.status_code == 200:
            data = resp.json()
            return float(data.get('price', data.get('lastPrice', 0)))
        return None
    except Exception as e:
        print(f"Errore API {symbol}: {e}")
        return None

def main():
    print(f"🔔 Trading Alert - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("-" * 40)
    
    for symbol, threshold in ALERTS.items():
        price = get_price(symbol)
        if price:
            print(f"{symbol}: ${price:,.2f} (soglia: ${threshold:,})")
            if price < threshold:
                msg = f"⚠️ ALERT: {symbol} sceso sotto ${threshold:,}!\nPrezzo attuale: ${price:,.2f}"
                send_telegram(msg)
        else:
            print(f"{symbol}: Errore nel recupero prezzo")
    
    print("-" * 40)

if __name__ == "__main__":
    main()
