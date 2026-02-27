# 🔐 CryptoApp

A powerful macOS app for text and file encryption, built with SwiftUI and Apple's CryptoKit framework.

## Features

- **AES Encryption** — Encrypt and decrypt text using AES-GCM (256-bit)
- **SHA Hashing** — Generate SHA256 and SHA512 hashes
- **Digital Signatures** — Sign and verify messages with ECDSA (P-256)
- **File Encryption** — Encrypt and decrypt files with AES
- **QR Code Generator** — Export encrypted output as QR code
- **History** — Track all operations with timestamps
- **Keychain** — Save and load keys securely from macOS Keychain
- **Share** — Share output via native macOS sharing panel
- **Dark Mode** — Automatic light/dark theme support

## Requirements

- macOS 13.0+
- Xcode 15+

## Installation

### From Source

```bash
git clone https://github.com/popo83/cryptoapp.git
cd cryptoapp
xcodegen generate
open CryptoApp.xcodeproj
```

Then build and run with **Cmd + R** in Xcode.

### Prerequisites

Install XcodeGen if not already installed:

```bash
brew install xcodegen
```

## Usage

### AES Encryption
1. Select **AES** mode
2. Click **Genera** to generate a key (or load from Keychain)
3. Enter your text
4. Click **Crittografa** to encrypt or **Decrittografa** to decrypt

### Hashing
1. Select **SHA256** or **SHA512** mode
2. Enter your text
3. Click **Hash**

### Digital Signature
1. Go to **Firma** tab
2. Click **Genera Keypair** to create ECDSA keys
3. Enter text and click **Firma** to sign
4. Click **Verifica** to verify the signature

### File Encryption
1. Go to **File** tab
2. Generate or enter an AES key
3. Click **Seleziona File** to choose a file
4. Click **Cifra File** or **Decifra File**

## Technologies

- **SwiftUI** — Modern declarative UI
- **CryptoKit** — Apple's native cryptography framework
- **Security framework** — Keychain integration
- **CoreImage** — QR code generation

## License

MIT License — see [LICENSE](LICENSE) for details.

## Author

Built with ❤️ and OpenClaw AI 🦞
