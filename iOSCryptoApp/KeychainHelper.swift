import Foundation
import Security

struct HistoryItem: Codable {
    let id: UUID
    let operation: String
    let input: String
    let output: String
    let date: Date
    
    init(operation: String, input: String, output: String, date: Date = Date()) {
        self.id = UUID()
        self.operation = operation
        self.input = input
        self.output = output
        self.date = date
    }
}

enum KeychainHelper {
    static func saveKey(_ key: String, forAccount account: String) {
        let data = Data(key.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func loadKey(forAccount account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    static func deleteKey(forAccount account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    static func deleteKeys(prefix: String, name: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "\(prefix)\(name)"
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    static func deleteECKeys(name: String) {
        let privateQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "CryptoApp_ECPrivate_\(name)"
        ]
        SecItemDelete(privateQuery as CFDictionary)
        
        let publicQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "CryptoApp_ECPublic_\(name)"
        ]
        SecItemDelete(publicQuery as CFDictionary)
    }
    
    static func listKeys(prefix: String) -> [String] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: true
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let items = result as? [[String: Any]] else { return [] }
        
        var names: [String] = []
        for item in items {
            if let account = item[kSecAttrAccount as String] as? String,
               account.hasPrefix(prefix) {
                let name = String(account.dropFirst(prefix.count))
                names.append(name)
            }
        }
        return names.sorted()
    }
}
