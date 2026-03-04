#!/usr/bin/env python3
"""
Portfolio Tracker - tracks crypto holdings from local CSV
"""

import csv
import os
from datetime import datetime

# Configuration
PORTFOLIO_FILE = os.path.expanduser("~/Documents/portfolio.csv")
TELEGRAM_CHAT_ID = "1075906736"

def get_crypto_prices(symbols):
    """Get prices from CoinGecko"""
    import requests
    try:
        ids = ",".join([s.lower() for s in symbols])
        url = f"https://api.coingecko.com/api/v3/simple/price?ids={ids}&vs_currencies=usd"
        resp = requests.get(url, timeout=10)
        return resp.json()
    except Exception as e:
        print(f"Errore API: {e}")
        return {}

def load_portfolio():
    """Load portfolio from CSV file"""
    holdings = []
    if os.path.exists(PORTFOLIO_FILE):
        with open(PORTFOLIO_FILE, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                holdings.append({
                    'symbol': row.get('symbol', '').upper(),
                    'amount': float(row.get('amount', 0))
                })
    return holdings

def send_telegram(message):
    """Send to Telegram"""
    try:
        import subprocess
        script = f'''tell application "Messages" to send "{message}" to buddy id "{TELEGRAM_CHAT_ID}"'''
        subprocess.run(["osascript", "-e", script], timeout=30, capture_output=True)
    except:
        pass

def main():
    print(f"📊 Portfolio Tracker - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("-" * 50)
    
    holdings = load_portfolio()
    if not holdings:
        print("⚠️ Nessun portafoglio trovato!")
        print(f"Crea un file CSV in: {PORTFOLIO_FILE}")
        print("Formato: symbol,amount")
        print("Esempio: BTC,0.5")
        return
    
    # Get unique symbols
    symbols = list(set([h['symbol'] for h in holdings]))
    prices = get_crypto_prices(symbols)
    
    total_value = 0
    print(f"{'Symbol':<10} {'Amount':<12} {'Price':<12} {'Value'}")
    print("-" * 50)
    
    for h in holdings:
        symbol = h['symbol'].lower()
        amount = h['amount']
        price = prices.get(symbol, {}).get('usd', 0)
        value = amount * price
        total_value += value
        print(f"{h['symbol']:<10} {amount:<12.4f} ${price:<11.2f} ${value:,.2f}")
    
    print("-" * 50)
    print(f"TOTAL PORTFOLIO VALUE: ${total_value:,.2f}")
    print("-" * 50)

if __name__ == "__main__":
    main()
