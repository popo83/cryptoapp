import requests

API_KEY = "sk_f0fb6161f1d1a2426d1e67c4fcff341b3e95d5380db2e3fa"

def list_voices():
    url = "https://api.elevenlabs.io/v1/voices"
    headers = {
        "xi-api-key": API_KEY,
    }
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        voices = response.json()
        for voice in voices.get("voices", []):
            print(f"ID: {voice['voice_id']} - Name: {voice['name']}")
    else:
        print("Errore nel recuperare le voci:")
        print(response.text)

if __name__ == "__main__":
    list_voices()
