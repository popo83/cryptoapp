import json
import subprocess
from datetime import datetime

LOGFILE = 'openclaw_usage_log.jsonl'

def get_session_status():
    try:
        result = subprocess.run(['openclaw', 'session_status', '--json'],
                                capture_output=True, text=True, check=True)
        data = json.loads(result.stdout)
        return data
    except Exception as e:
        print(f'Errore: {e}')
        return None

def log_status(data):
    with open(LOGFILE, 'a') as f:
        timestamp = datetime.now().isoformat()
        f.write(json.dumps({'timestamp': timestamp, 'data': data}) + '\n')

if __name__ == '__main__':
    status = get_session_status()
    if status:
        log_status(status)
        print('Status OpenClaw loggato.')
    else:
        print('Errore nel recupero dello status.')
