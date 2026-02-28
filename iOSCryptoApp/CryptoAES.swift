import Foundation
import CryptoKit

enum CryptoAES {
    static func encrypt(_ plaintext: String, key: String) throws -> String {
        guard let keyData = Data(base64Encoded: key) else { throw CryptoError.invalidKey }
        let symmetricKey = SymmetricKey(data: keyData)
        let sealedBox = try AES.GCM.seal(plaintext.data(using: .utf8)!, using: symmetricKey)
        guard let combined = sealedBox.combined else { throw CryptoError.encryptionFailed }
        return combined.base64EncodedString()
    }
    
    static func decrypt(_ ciphertext: String, key: String) throws -> String {
        guard let keyData = Data(base64Encoded: key), let data = Data(base64Encoded: ciphertext) else {
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

enum CryptoError: Error {
    case invalidKey
    case encryptionFailed
    case decryptionFailed
}
