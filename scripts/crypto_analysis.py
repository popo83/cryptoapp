#!/usr/bin/env python3
"""
Crypto Analysis Script - calculates RSI, MACD, and other indicators
"""

import requests
import json
from datetime import datetime

def get_ohlc_data(symbol="bitcoin", days=30):
    """Get OHLC data from CoinGecko"""
    try:
        url = f"https://api.coingecko.com/api/v3/coins/{symbol}/ohlc?vs_currency=usd&days={days}"
        resp = requests.get(url, timeout=30)
        return resp.json()
    except Exception as e:
        print(f"Errore: {e}")
        return []

def calculate_sma(prices, period):
    """Simple Moving Average"""
    if len(prices) < period:
        return []
    sma = []
    for i in range(len(prices) - period + 1):
        avg = sum(prices[i:i+period]) / period
        sma.append(avg)
    return sma

def calculate_rsi(prices, period=14):
    """Relative Strength Index"""
    if len(prices) < period + 1:
        return []
    
    gains = []
    losses = []
    for i in range(1, len(prices)):
        change = prices[i] - prices[i-1]
        if change > 0:
            gains.append(change)
            losses.append(0)
        else:
            gains.append(0)
            losses.append(abs(change))
    
    rsi = []
    avg_gain = sum(gains[:period]) / period
    avg_loss = sum(losses[:period]) / period
    
    for i in range(period, len(gains)):
        avg_gain = (avg_gain * (period - 1) + gains[i]) / period
        avg_loss = (avg_loss * (period - 1) + losses[i]) / period
        
        if avg_loss == 0:
            rsi.append(100)
        else:
            rs = avg_gain / avg_loss
            rsi_value = 100 - (100 / (1 + rs))
            rsi.append(rsi_value)
    
    return rsi

def calculate_macd(prices, fast=12, slow=26, signal=9):
    """MACD - Moving Average Convergence Divergence"""
    if len(prices) < slow:
        return None, None, None
    
    ema_fast = calculate_sma(prices, fast)  # Simplified using SMA
    ema_slow = calculate_sma(prices, slow)
    
    macd_line = []
    for i in range(len(ema_slow)):
        if i < len(ema_fast):
            macd_line.append(ema_fast[i] - ema_slow[i])
    
    signal_line = calculate_sma(macd_line, signal) if len(macd_line) >= signal else []
    
    return macd_line, signal_line, None

def main():
    symbol = input("Symbol (es. bitcoin, ethereum): ").strip().lower() or "bitcoin"
    days = int(input("Giorni di storico (30-365): ").strip() or "30")
    
    print(f"\n📊 Analisi {symbol.upper()} - {datetime.now().strftime('%Y-%m-%d')}")
    print("-" * 50)
    
    data = get_ohlc_data(symbol, days)
    if not data:
        print("❌ Errore nel recupero dati")
        return
    
    # Extract closing prices
    prices = [d[4] for d in data]  # OHLC: timestamp, open, high, low, close
    
    print(f"Prezzo attuale: ${prices[-1]:,.2f}")
    print(f"Prezzo {days} giorni fa: ${prices[0]:,.2f}")
    print(f"Variazione: {((prices[-1] - prices[0]) / prices[0] * 100):.2f}%\n")
    
    # SMA
    sma_20 = calculate_sma(prices, 20)
    sma_50 = calculate_sma(prices, 50)
    
    if sma_20:
        print(f"SMA 20: ${sma_20[-1]:,.2f}")
    if sma_50:
        print(f"SMA 50: ${sma_50[-1]:,.2f}")
    
    # RSI
    rsi = calculate_rsi(prices)
    if rsi:
        print(f"\nRSI (14): {rsi[-1]:.2f}")
        if rsi[-1] > 70:
            print("⚠️ Ipercomprato (possibile ribasso)")
        elif rsi[-1] < 30:
            print("⚠️ Ipervenduto (possibile rialzo)")
        else:
            print("✅ Neutro")
    
    print("-" * 50)

if __name__ == "__main__":
    main()
