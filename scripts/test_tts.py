import requests

API_KEY = "sk_0c9e18033386eb934135902b6da92b30ae30322fc98982e5"
VOICE_ID = "pNInz6obpgDQGcFmaJgB"  # Roger voice

def tts(text):
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{VOICE_ID}"
    headers = {
        "Content-Type": "application/json",
        "xi-api-key": API_KEY,
    }
    json_data = {
        "text": text,
        "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.8
        }
    }

    response = requests.post(url, headers=headers, json=json_data)
    print(f"Status code: {response.status_code}")
    if response.status_code == 200:
        print("Audio data received successfully.")
        output_path = "~/Desktop/output.mp3"
        import os
        output_path = os.path.expanduser(output_path)
        with open(output_path, "wb") as f:
            f.write(response.content)
        print(f"Audio saved to {output_path}")
    else:
        print("Error response:")
        print(response.text)

if __name__ == "__main__":
    text = input("Enter text to synthesize: ")
    tts(text)
