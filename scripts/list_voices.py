import requests

API_KEY = "sk_0c9e18033386eb934135902b6da92b30ae30322fc98982e5"

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
