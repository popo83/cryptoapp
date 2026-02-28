# skill_browser_relay.py

import subprocess
import time

class BrowserRelayManager:
    def __init__(self, port=18803, token=None):
        self.port = port
        self.token = token
        self.profile = "chrome"
    
    def check_status(self):
        """Verifica stato connessione Browser Relay"""
        try:
            result = subprocess.run(
                ["lsof", "-i", f":{self.port}"],
                capture_output=True,
                text=True,
                timeout=10
            )
            if result.stdout:
                print(f"✅ Porta {self.port} è in uso")
                return True
            else:
                print(f"⚠️ Porta {self.port} non in uso")
                return False
        except Exception as e:
            print(f"❌ Errore: {e}")
            return False
    
    def check_chrome_extension(self):
        """Verifica se estensione Chrome è installata e connessa"""
        # Placeholder - richiede interazione con browser
        print("🔍 Verifica estensione Chrome Browser Relay...")
        print("Apri Chrome e clicca sull'icona dell'estensione nella toolbar")
        return None
    
    def reconnect(self):
        """Tentativo riconnessione"""
        print(f"🔄 Tentativo riconnessione alla porta {self.port}...")
        # Riavviare processo browser o gateway
        print("💡 Suggerimento: Chiudi e riapri Chrome, poi reconnetti l'estensione")
    
    def test_connection(self, url="https://appstoreconnect.apple.com"):
        """Testa connessione a URL"""
        try:
            result = subprocess.run(
                ["curl", "-s", "-o", "/dev/null", "-w", "%{http_code}", url],
                capture_output=True,
                text=True,
                timeout=30
            )
            status = result.stdout.strip()
            print(f"🌐 Test connessione {url}: {status}")
            return status == "200"
        except Exception as e:
            print(f"❌ Errore test: {e}")
            return False

# Esempio uso
if __name__ == "__main__":
    manager = BrowserRelayManager(port=18803, token="mytoken123")
    manager.check_status()
    manager.test_connection()
