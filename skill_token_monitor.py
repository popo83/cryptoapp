# skill_token_monitor.py

import subprocess
import json
from datetime import datetime

class TokenMonitor:
    def __init__(self):
        self.session_file = None
    
    def get_session_status(self):
        """Recupera stato sessione OpenClaw"""
        try:
            result = subprocess.run(
                ["openclaw", "status"],
                capture_output=True,
                text=True,
                timeout=30
            )
            output = result.stdout
            
            # Estrai info token e costi
            tokens_in = 0
            tokens_out = 0
            cost = 0.0
            
            for line in output.split('\n'):
                if "Tokens:" in line:
                    parts = line.split("Tokens:")[1].split("/")
                    if len(parts) >= 2:
                        tokens_in = parts[0].strip()
                        tokens_out = parts[1].strip().split()[0] if parts[1] else "0"
                if "Cost:" in line:
                    cost = line.split("Cost:")[1].strip().split()[0]
            
            return {
                "tokens_in": tokens_in,
                "tokens_out": tokens_out,
                "cost": cost,
                "timestamp": datetime.now().isoformat()
            }
        except Exception as e:
            print(f"❌ Errore: {e}")
            return None
    
    def check_costs(self, threshold=30.0):
        """Verifica se superata soglia costi"""
        status = self.get_session_status()
        if status:
            try:
                current_cost = float(status["cost"].replace("$", ""))
                if current_cost > threshold:
                    print(f"⚠️ ATTENZIONE: Costo ${current_cost} supera soglia ${threshold}!")
                    return True
                else:
                    print(f"✅ Costo OK: ${current_cost} (soglia: ${threshold})")
                    return False
            except:
                pass
        return None
    
    def log_usage(self, log_file="token_usage.log"):
        """Salva log utilizzo"""
        status = self.get_session_status()
        if status:
            with open(log_file, "a") as f:
                f.write(f"{status['timestamp']}: in={status['tokens_in']}, out={status['tokens_out']}, cost={status['cost']}\n")
            print(f"✅ Log salvato su {log_file}")
    
    def suggest_model(self):
        """Suggerisce modello basato su utilizzo"""
        status = self.get_session_status()
        if status:
            try:
                tokens_in = int(status["tokens_in"].replace("k", "000"))
                if tokens_in > 500000:
                    print("💡 Suggerimento: Usa modello più piccolo (es. gpt-4.1-mini)")
                else:
                    print("💡 Modello attuale OK")
            except:
                pass

# Esempio uso
if __name__ == "__main__":
    monitor = TokenMonitor()
    status = monitor.get_session_status()
    if status:
        print(f"Tokens: {status['tokens_in']} in / {status['tokens_out']} out")
        print(f"Costo: {status['cost']}")
    
    monitor.check_costs(threshold=30.0)
    monitor.log_usage()
