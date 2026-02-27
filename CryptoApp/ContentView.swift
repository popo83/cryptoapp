import SwiftUI
import CryptoKit
import Security
import CoreImage
import CoreImage.CIFilterBuiltins
import UniformTypeIdentifiers

@main
struct CryptoAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - History Item

struct HistoryItem: Identifiable, Codable {
    let id = UUID()
    let operation: String
    let input: String
    let output: String
    let date: Date
}

struct ContentView: View {
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var selectedMode = "AES"
    @State private var selectedTab = "Cripto"
    @State private var key = ""
    @State private var hashOutput = ""
    @State private var isDarkMode = false
    @State private var showCopied = false
    @State private var animateButton = false
    @State private var history: [HistoryItem] = []
    @State private var showQR = false
    @State private var qrImage: NSImage? = nil
    @State private var privateKeyPEM = ""
    @State private var publicKeyPEM = ""
    @State private var signatureOutput = ""
    @State private var verifyResult = ""
    @State private var selectedFile: URL? = nil
    @State private var fileOutputURL: URL? = nil

    let modes = ["AES", "SHA256", "SHA512"]
    let tabs = ["Cripto", "Firma", "File", "Storico"]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: isDarkMode ? [Color.black, Color(hex: "#1a1a2e")] : [Color(hex: "#f0f4ff"), Color(hex: "#e8f0fe")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("🔐 CryptoApp")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(isDarkMode ? .white : .primary)
                    Spacer()
                    Toggle("", isOn: $isDarkMode)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                .padding()

                // Tab Bar
                HStack(spacing: 0) {
                    ForEach(tabs, id: \.self) { tab in
                        Button(tab) { selectedTab = tab }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selectedTab == tab ? Color.blue : Color.clear)
                            .foregroundColor(selectedTab == tab ? .white : (isDarkMode ? .white : .primary))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                ScrollView {
                    switch selectedTab {
                    case "Cripto": cryptoView
                    case "Firma": firmaView
                    case "File": fileView
                    case "Storico": storicoView
                    default: cryptoView
                    }
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .frame(minWidth: 500, minHeight: 600)
    }

    // MARK: - Cripto View

    var cryptoView: some View {
        VStack(spacing: 20) {
            Picker("Modalità", selection: $selectedMode) {
                ForEach(modes, id: \.self) { mode in Text(mode).tag(mode) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Testo Input").font(.headline).foregroundColor(isDarkMode ? .white : .primary)
                    Spacer()
                    Button { if let clip = NSPasteboard.general.string(forType: .string) { inputText = clip } } label: {
                        Label("Incolla", systemImage: "doc.on.clipboard").font(.caption)
                    }.buttonStyle(.bordered)
                }
                TextEditor(text: $inputText)
                    .frame(height: 100).padding(8)
                    .background(isDarkMode ? Color(hex: "#2a2a3e") : Color.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue.opacity(0.3), lineWidth: 1))
            }
            .padding(.horizontal)

            if selectedMode == "AES" {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Chiave AES").font(.headline).foregroundColor(isDarkMode ? .white : .primary)
                    HStack {
                        TextField("Chiave Base64", text: $key).textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Genera") { withAnimation { key = CryptoAES.generateKey() } }.buttonStyle(.borderedProminent)
                        Button("Salva") { KeychainHelper.saveKey(key, forAccount: "CryptoApp_AES") }.buttonStyle(.bordered)
                        Button("Carica") { key = KeychainHelper.loadKey(forAccount: "CryptoApp_AES") ?? "" }.buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)
            }

            HStack(spacing: 12) {
                Button { processEncrypt() } label: { Label("Crittografa", systemImage: "lock.fill").frame(maxWidth: .infinity) }
                    .buttonStyle(.borderedProminent).scaleEffect(animateButton ? 0.95 : 1.0)
                Button { processDecrypt() } label: { Label("Decrittografa", systemImage: "lock.open.fill").frame(maxWidth: .infinity) }
                    .buttonStyle(.bordered)
                Button { processHash() } label: { Label("Hash", systemImage: "number").frame(maxWidth: .infinity) }
                    .buttonStyle(.bordered)
            }
            .padding(.horizontal)

            if !outputText.isEmpty || !hashOutput.isEmpty {
                outputSection
            }
        }
        .padding(.vertical)
    }

    // MARK: - Firma View

    var firmaView: some View {
        VStack(spacing: 16) {
            Text("Firma Digitale (ECDSA)").font(.headline).foregroundColor(isDarkMode ? .white : .primary)

            Button("Genera Keypair") { generateECDSAKeys() }
                .buttonStyle(.borderedProminent)

            if !privateKeyPEM.isEmpty {
                Group {
                    VStack(alignment: .leading) {
                        Text("Chiave Privata").font(.caption).foregroundColor(.gray)
                        Text(privateKeyPEM).font(.system(.caption2, design: .monospaced))
                            .padding(8).background(isDarkMode ? Color(hex: "#2a2a3e") : Color.white)
                            .cornerRadius(8).lineLimit(4)
                    }
                    VStack(alignment: .leading) {
                        Text("Chiave Pubblica").font(.caption).foregroundColor(.gray)
                        Text(publicKeyPEM).font(.system(.caption2, design: .monospaced))
                            .padding(8).background(isDarkMode ? Color(hex: "#2a2a3e") : Color.white)
                            .cornerRadius(8).lineLimit(4)
                    }
                }
                .padding(.horizontal)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Testo da firmare").font(.headline).foregroundColor(isDarkMode ? .white : .primary)
                TextEditor(text: $inputText).frame(height: 80).padding(8)
                    .background(isDarkMode ? Color(hex: "#2a2a3e") : Color.white).cornerRadius(10)
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                Button("Firma") { signMessage() }.buttonStyle(.borderedProminent)
                Button("Verifica") { verifySignature() }.buttonStyle(.bordered)
            }

            if !signatureOutput.isEmpty {
                VStack(alignment: .leading) {
                    Text("Firma:").font(.caption).foregroundColor(.gray)
                    Text(signatureOutput).font(.system(.caption2, design: .monospaced))
                        .padding(8).background(isDarkMode ? Color(hex: "#2a2a3e") : Color.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }

            if !verifyResult.isEmpty {
                Text(verifyResult)
                    .foregroundColor(verifyResult.contains("✅") ? .green : .red)
                    .font(.headline)
            }
        }
        .padding(.vertical)
    }

    // MARK: - File View

    var fileView: some View {
        VStack(spacing: 16) {
            Text("Crittografia File").font(.headline).foregroundColor(isDarkMode ? .white : .primary)

            if selectedMode == "AES" {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Chiave AES").font(.subheadline).foregroundColor(isDarkMode ? .white : .primary)
                    HStack {
                        TextField("Chiave Base64", text: $key).textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Genera") { key = CryptoAES.generateKey() }.buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)
            }

            Button("Seleziona File") { selectFile() }.buttonStyle(.borderedProminent)

            if let url = selectedFile {
                Text("📄 \(url.lastPathComponent)").foregroundColor(.blue)
            }

            HStack(spacing: 12) {
                Button("Cifra File") { encryptFile() }.buttonStyle(.borderedProminent)
                Button("Decifra File") { decryptFile() }.buttonStyle(.bordered)
            }

            if let outURL = fileOutputURL {
                Text("✅ Salvato: \(outURL.lastPathComponent)").foregroundColor(.green)
                    .font(.caption)
            }
        }
        .padding(.vertical)
    }

    // MARK: - Storico View

    var storicoView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Storico Operazioni").font(.headline).foregroundColor(isDarkMode ? .white : .primary)
                Spacer()
                Button("Cancella") { history.removeAll(); saveHistory() }
                    .buttonStyle(.bordered).tint(.red)
            }
            .padding(.horizontal)

            if history.isEmpty {
                Text("Nessuna operazione").foregroundColor(.gray).padding()
            } else {
                ForEach(history.reversed()) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.operation).font(.headline).foregroundColor(.blue)
                            Spacer()
                            Text(item.date, style: .time).font(.caption).foregroundColor(.gray)
                        }
                        Text("Input: \(item.input.prefix(40))...").font(.caption).foregroundColor(.gray)
                        Text("Output: \(item.output.prefix(40))...").font(.caption2).foregroundColor(.secondary)
                    }
                    .padding(10)
                    .background(isDarkMode ? Color(hex: "#2a2a3e") : Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .onAppear { loadHistory() }
    }

    // MARK: - Output Section

    var outputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Output").font(.headline).foregroundColor(isDarkMode ? .white : .primary)
                Spacer()
                Button {
                    let result = outputText.isEmpty ? hashOutput : outputText
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(result, forType: .string)
                    withAnimation { showCopied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { showCopied = false } }
                } label: {
                    Label(showCopied ? "Copiato!" : "Copia", systemImage: showCopied ? "checkmark" : "doc.on.doc").font(.caption)
                }
                .buttonStyle(.bordered).tint(showCopied ? .green : .blue)

                Button {
                    let result = outputText.isEmpty ? hashOutput : outputText
                    ShareHelper.share(text: result)
                } label: {
                    Label("Condividi", systemImage: "square.and.arrow.up").font(.caption)
                }
                .buttonStyle(.bordered).tint(.orange)

                Button {
                    let result = outputText.isEmpty ? hashOutput : outputText
                    qrImage = QRCodeGenerator.generate(from: result)
                    showQR = true
                } label: {
                    Label("QR", systemImage: "qrcode").font(.caption)
                }
                .buttonStyle(.bordered).tint(.purple)
            }

            Text(outputText.isEmpty ? hashOutput : outputText)
                .font(.system(.body, design: .monospaced))
                .padding(8).frame(maxWidth: .infinity, alignment: .leading)
                .background(isDarkMode ? Color(hex: "#2a2a3e") : Color.white)
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showQR) {
            VStack(spacing: 16) {
                Text("QR Code").font(.headline)
                if let img = qrImage {
                    Image(nsImage: img).resizable().frame(width: 200, height: 200)
                }
                Button("Chiudi") { showQR = false }.buttonStyle(.borderedProminent)
            }
            .padding(30)
        }
    }

    // MARK: - Functions

    func processEncrypt() {
        hashOutput = ""
        if selectedMode == "AES" && !key.isEmpty {
            outputText = (try? CryptoAES.encrypt(inputText, key: key)) ?? "Errore"
        } else {
            outputText = selectedMode == "AES" ? "Inserisci una chiave" : "Seleziona AES"
        }
        addHistory(operation: "Crittografa (\(selectedMode))", input: inputText, output: outputText)
    }

    func processDecrypt() {
        hashOutput = ""
        if selectedMode == "AES" && !key.isEmpty {
            outputText = (try? CryptoAES.decrypt(inputText, key: key)) ?? "Errore"
        } else {
            outputText = selectedMode == "AES" ? "Inserisci una chiave" : "Seleziona AES"
        }
        addHistory(operation: "Decrittografa (\(selectedMode))", input: inputText, output: outputText)
    }

    func processHash() {
        outputText = ""
        hashOutput = selectedMode == "SHA256" ? CryptoHash.sha256(inputText) : (selectedMode == "SHA512" ? CryptoHash.sha512(inputText) : "Seleziona SHA")
        addHistory(operation: "Hash (\(selectedMode))", input: inputText, output: hashOutput)
    }

    func generateECDSAKeys() {
        let privateKey = P256.Signing.PrivateKey()
        privateKeyPEM = privateKey.pemRepresentation
        publicKeyPEM = privateKey.publicKey.pemRepresentation
    }

    func signMessage() {
        guard !privateKeyPEM.isEmpty, let privateKey = try? P256.Signing.PrivateKey(pemRepresentation: privateKeyPEM) else {
            signatureOutput = "Chiave privata non valida"
            return
        }
        guard let data = inputText.data(using: .utf8),
              let signature = try? privateKey.signature(for: data) else {
            signatureOutput = "Errore nella firma"
            return
        }
        signatureOutput = signature.derRepresentation.base64EncodedString()
        addHistory(operation: "Firma ECDSA", input: inputText, output: signatureOutput)
    }

    func verifySignature() {
        guard !publicKeyPEM.isEmpty, !signatureOutput.isEmpty,
              let publicKey = try? P256.Signing.PublicKey(pemRepresentation: publicKeyPEM),
              let data = inputText.data(using: .utf8),
              let sigData = Data(base64Encoded: signatureOutput),
              let signature = try? P256.Signing.ECDSASignature(derRepresentation: sigData) else {
            verifyResult = "❌ Dati non validi"
            return
        }
        verifyResult = publicKey.isValidSignature(signature, for: data) ? "✅ Firma valida!" : "❌ Firma non valida"
    }

    func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        if panel.runModal() == .OK {
            selectedFile = panel.url
        }
    }

    func encryptFile() {
        guard let url = selectedFile, !key.isEmpty,
              let data = try? Data(contentsOf: url),
              let keyData = Data(base64Encoded: key) else { return }
        let symmetricKey = SymmetricKey(data: keyData)
        guard let sealedBox = try? AES.GCM.seal(data, using: symmetricKey),
              let combined = sealedBox.combined else { return }
        let outURL = url.deletingPathExtension().appendingPathExtension("enc")
        try? combined.write(to: outURL)
        fileOutputURL = outURL
        addHistory(operation: "Cifra File", input: url.lastPathComponent, output: outURL.lastPathComponent)
    }

    func decryptFile() {
        guard let url = selectedFile, !key.isEmpty,
              let data = try? Data(contentsOf: url),
              let keyData = Data(base64Encoded: key) else { return }
        let symmetricKey = SymmetricKey(data: keyData)
        guard let sealedBox = try? AES.GCM.SealedBox(combined: data),
              let decrypted = try? AES.GCM.open(sealedBox, using: symmetricKey) else { return }
        let outURL = url.deletingPathExtension().appendingPathExtension("dec")
        try? decrypted.write(to: outURL)
        fileOutputURL = outURL
        addHistory(operation: "Decifra File", input: url.lastPathComponent, output: outURL.lastPathComponent)
    }

    func addHistory(operation: String, input: String, output: String) {
        let item = HistoryItem(operation: operation, input: input, output: output, date: Date())
        history.append(item)
        saveHistory()
    }

    func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: "CryptoHistory")
        }
    }

    func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "CryptoHistory"),
           let saved = try? JSONDecoder().decode([HistoryItem].self, from: data) {
            history = saved
        }
    }
}

// MARK: - Keychain Helper

enum KeychainHelper {
    static func saveKey(_ key: String, forAccount account: String) {
        let data = Data(key.utf8)
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: account, kSecValueData as String: data]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func loadKey(forAccount account: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: account, kSecReturnData as String: true, kSecMatchLimit as String: kSecMatchLimitOne]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Share Helper

enum ShareHelper {
    static func share(text: String) {
        guard let window = NSApplication.shared.keyWindow, let view = window.contentView else { return }
        let picker = NSSharingServicePicker(items: [text])
        picker.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
    }
}

// MARK: - QR Code Generator

enum QRCodeGenerator {
    static func generate(from text: String) -> NSImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = "H"
        guard let ciImage = filter.outputImage else { return nil }
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return NSImage(cgImage: cgImage, size: NSSize(width: 200, height: 200))
    }
}

// MARK: - Crypto Functions

enum CryptoAES {
    static func encrypt(_ plaintext: String, key: String) throws -> String {
        guard let keyData = Data(base64Encoded: key) else { throw CryptoError.invalidKey }
        let symmetricKey = SymmetricKey(data: keyData)
        let sealedBox = try AES.GCM.seal(plaintext.data(using: .utf8)!, using: symmetricKey)
        guard let combined = sealedBox.combined else { throw CryptoError.encryptionFailed }
        return combined.base64EncodedString()
    }

    static func decrypt(_ ciphertext: String, key: String) throws -> String {
        guard let keyData = Data(base64Encoded: key), let data = Data(base64Encoded: ciphertext) else { throw CryptoError.invalidKey }
        let symmetricKey = SymmetricKey(data: keyData)
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
        guard let plaintext = String(data: decryptedData, encoding: .utf8) else { throw CryptoError.decryptionFailed }
        return plaintext
    }

    static func generateKey() -> String {
        let key = SymmetricKey(size: .bits256)
        return key.withUnsafeBytes { Data($0).base64EncodedString() }
    }
}

enum CryptoHash {
    static func sha256(_ text: String) -> String { SHA256.hash(data: Data(text.utf8)).compactMap { String(format: "%02x", $0) }.joined() }
    static func sha512(_ text: String) -> String { SHA512.hash(data: Data(text.utf8)).compactMap { String(format: "%02x", $0) }.joined() }
}

enum CryptoError: Error { case invalidKey, encryptionFailed, decryptionFailed }

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(red: Double((int >> 16) & 0xFF) / 255, green: Double((int >> 8) & 0xFF) / 255, blue: Double(int & 0xFF) / 255)
    }
}

#Preview { ContentView() }
