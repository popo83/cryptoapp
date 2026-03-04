#!/usr/bin/env python3
import json
import subprocess
import re
from datetime import datetime

LOGFILE = '/Users/jacopochimenti/documenti/openclaw/api_usage_log.jsonl'

def get_status():
    try:
        result = subprocess.run(['openclaw', 'status'], 
                              capture_output=True, text=True, timeout=30)
        output = result.stdout
        
        # Parse key metrics from output
        data = {
            'timestamp': datetime.now().isoformat(),
            'gateway_reachable': 'reachable' in output,
            'agents': None,
            'sessions': None,
            'memory_files': None,
            'cache': None
        }
        
        # Extract agents count
        match = re.search(r'Agents\s+│\s+(\d+)', output)
        if match:
            data['agents'] = int(match.group(1))
            
        # Extract sessions count
        match = re.search(r'sessions\s+(\d+)', output)
        if match:
            data['sessions'] = int(match.group(1))
            
        # Extract memory files
        match = re.search(r'Memory\s+│\s+(\d+)\s+files', output)
        if match:
            data['memory_files'] = int(match.group(1))
            
        # Extract cache
        match = re.search(r'cache on \((\d+)\)', output)
        if match:
            data['cache'] = int(match.group(1))
            
        return data
        
    except Exception as e:
        print(f"Errore: {e}")
        return None

def log_status(data):
    with open(LOGFILE, 'a') as f:
        f.write(json.dumps(data) + '\n')
    print(f"Loggato: {data['timestamp']}")

if __name__ == '__main__':
    status = get_status()
    if status:
        log_status(status)
    else:
        print("Nessun dato salvato")
