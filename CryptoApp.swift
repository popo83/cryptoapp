import SwiftUI
import CryptoKit

struct ContentView: View {
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var selectedMode = "AES"
    @State private var key = ""
    @State private var hashOutput = ""
    
    let modes = ["AES", "SHA256", "SHA512"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Crittografia SwiftUI")
                .font(.largeTitle)
                .padding()
            
            Picker("Modalità", selection: $selectedMode) {
                ForEach(modes, id: \.self) { mode in
                    Text(mode).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Testo Input:")
                    .font(.headline)
                TextEditor(text: $inputText)
                    .frame(height: 100)
                    .border(Color.gray)
            }
            .padding(.horizontal)
            
            if selectedMode == "AES" {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Chiave (Base64):")
                        .font(.headline)
                    TextField("Inserisci la chiave", text: $key)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
            }
            
            HStack(spacing: 20) {
                Button("Crittografa") {
                    processEncrypt()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Decrittografa") {
                    processDecrypt()
                }
                .buttonStyle(.bordered)
                
                Button("Hash") {
                    processHash()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Output:")
                    .font(.headline)
                TextEditor(text: $outputText)
                    .frame(height: 100)
                    .border(Color.gray)
            }
            .padding(.horizontal)
            
            if !hashOutput.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hash:")
                        .font(.headline)
                    Text(hashOutput)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
    
    func processEncrypt() {
        switch selectedMode {
        case "AES":
            if let data = try? CryptoAES.encrypt(inputText, key: key) {
                outputText = data
            } else {
                outputText = "Errore nella crittografia"
            }
        default:
            outputText = "Seleziona AES per crittografare"
        }
    }
    
    func processDecrypt() {
        switch selectedMode {
        case "AES":
            if let data = try? CryptoAES.decrypt(inputText, key: key) {
                outputText = data
            } else {
                outputText = "Errore nella decrittografia"
            }
        default:
            outputText = "Seleziona AES per decrittografare"
        }
    }
    
    func processHash() {
        switch selectedMode {
        case "SHA256":
            hashOutput = CryptoHash.sha256(inputText)
        case "SHA512":
            hashOutput = CryptoHash.sha512(inputText)
        default:
            hashOutput = "Seleziona SHA256 o SHA512"
        }
    }
}

// ============================================
// Crypto Functions
// ============================================

enum CryptoAES {
    static func encrypt(_ plaintext: String, key: String) throws -> String {
        guard let keyData = Data(base64Encoded: key) else {
            throw CryptoError.invalidKey
        }
        let symmetricKey = SymmetricKey(data: keyData)
        let sealedBox = try AES.GCM.seal(plaintext.data(using: .utf8)!, using: symmetricKey)
        guard let combined = sealedBox.combined else {
            throw CryptoError.encryptionFailed
        }
        return combined.base64EncodedString()
    }
    
    static func decrypt(_ ciphertext: String, key: String) throws -> String {
        guard let keyData = Data(base64Encoded: key),
              let data = Data(base64Encoded: ciphertext) else {
            throw CryptoError.invalidKey
        }
        let symmetricKey = SymmetricKey(data: keyData)
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
        guard let plaintext = String(data: decryptedData, encoding: .utf8) else {
            throw CryptoError.decryptionFailed
        }
        return plaintext
    }
    
    static func generateKey() -> String {
        let key = SymmetricKey(size: .bits256)
        return key.withUnsafeBytes { Data($0).base64EncodedString() }
    }
}

enum CryptoHash {
    static func sha256(_ text: String) -> String {
        let data = Data(text.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    static func sha512(_ text: String) -> String {
        let data = Data(text.utf8)
        let hash = SHA512.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

enum CryptoError: Error {
    case invalidKey
    case encryptionFailed
    case decryptionFailed
}

#Preview {
    ContentView()
}
