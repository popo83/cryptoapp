# CryptoApp

CryptoApp is a powerful macOS application designed for secure text and file encryption, leveraging SwiftUI and Apple's CryptoKit framework for modern cryptography.

## Features

- **AES Encryption/Decryption:** Securely encrypt and decrypt text using AES-GCM with 256-bit keys.
- **SHA Hashing:** Generate SHA256 and SHA512 hashes for data integrity.
- **Digital Signatures:** Create and verify digital signatures with ECDSA (P-256).
- **File Encryption/Decryption:** Encrypt and decrypt files using AES.
- **QR Code Generation:** Export encrypted output as QR codes for easy sharing.
- **Operation History:** Track all cryptographic operations with timestamps.
- **Keychain Integration:** Save and load encryption keys securely with macOS Keychain.
- **Dark Mode Support:** Automatic theme switching for light/dark modes.
- **Native Share Sheet:** Easily share outputs using macOS's native sharing.

## Requirements

- macOS 13.0 or later
- Xcode 15 or later

## Installation

Clone the repository and generate the Xcode project using XcodeGen:

```bash
git clone https://github.com/popo83/cryptoapp.git
cd cryptoapp
xcodegen generate
open CryptoApp.xcodeproj
```

Then build and run the app in Xcode.

## Usage

### AES Encryption

1. Select AES mode.
2. Generate or load a base64-encoded AES key.
3. Input your plaintext.
4. Encrypt or decrypt with the buttons provided.

### SHA Hashing

1. Select SHA256 or SHA512 mode.
2. Input your data.
3. Click Hash to generate the hash.

### Digital Signatures

1. Generate an ECDSA keypair.
2. Input the message to sign.
3. Sign the message.
4. Verify existing signatures.

### File Encryption

1. Generate or provide AES key.
2. Select a file.
3. Encrypt or decrypt the file.

## License

This project is MIT licensed.

## Author

Developed with ❤️ and OpenClaw AI 🦞
