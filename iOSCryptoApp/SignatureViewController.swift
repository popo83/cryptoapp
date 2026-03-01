import UIKit
import CryptoKit

class SignatureViewController: UIViewController {
    
    var scrollView: UIScrollView!
    var contentView: UIView!
    
    var keyNameTextField: UITextField!
    var privateKeyTextView: UITextView!
    var publicKeyTextView: UITextView!
    var inputTextView: UITextView!
    var signatureTextView: UITextView!
    var savedKeysLabel: UILabel!
    var savedKeysStackView: UIStackView!
    var resultLabel: UILabel!
    
    var savedECKeys: [String] = []
    var currentECKeyName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Signature"
        view.backgroundColor = .systemBackground
        setupUI()
        loadSavedKeys()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupUI() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        let keyLabel = createSectionTitle("Key Management")
        contentView.addSubview(keyLabel)
        
        keyNameTextField = createTextField(placeholder: "Key pair name")
        contentView.addSubview(keyNameTextField)
        
        let buttonStack = createHorizontalStack()
        contentView.addSubview(buttonStack)
        
        let generateBtn = createButton(title: "Generate", image: "wand.and.stars", style: .primary)
        generateBtn.addTarget(self, action: #selector(generateKeypair), for: .touchUpInside)
        buttonStack.addArrangedSubview(generateBtn)
        
        let saveBtn = createButton(title: "Save", image: "square.and.arrow.down", style: .success)
        saveBtn.addTarget(self, action: #selector(saveKeys), for: .touchUpInside)
        buttonStack.addArrangedSubview(saveBtn)
        
        savedKeysLabel = createCaption("Your key pairs:")
        contentView.addSubview(savedKeysLabel)
        
        savedKeysStackView = createHorizontalStack()
        contentView.addSubview(savedKeysStackView)
        
        let privateLabel = createCaption("Private Key:")
        contentView.addSubview(privateLabel)
        
        privateKeyTextView = createTextView()
        contentView.addSubview(privateKeyTextView)
        
        let publicLabel = createCaption("Public Key:")
        contentView.addSubview(publicLabel)
        
        publicKeyTextView = createTextView()
        contentView.addSubview(publicKeyTextView)
        
        let divider1 = createDivider()
        contentView.addSubview(divider1)
        
        let inputLabel = createSectionTitle("Text to sign")
        contentView.addSubview(inputLabel)
        
        inputTextView = createTextView()
        contentView.addSubview(inputTextView)
        
        let inputPasteBtn = createSmallButton(image: "doc.on.clipboard", title: "Paste")
        inputPasteBtn.addTarget(self, action: #selector(pasteInput), for: .touchUpInside)
        contentView.addSubview(inputPasteBtn)
        
        let actionStack = createHorizontalStack()
        contentView.addSubview(actionStack)
        
        let signBtn = createButton(title: "Sign", image: "signature", style: .success)
        signBtn.addTarget(self, action: #selector(signText), for: .touchUpInside)
        actionStack.addArrangedSubview(signBtn)
        
        let verifyBtn = createButton(title: "Verify", image: "checkmark.shield", style: .warning)
        verifyBtn.addTarget(self, action: #selector(verifyText), for: .touchUpInside)
        actionStack.addArrangedSubview(verifyBtn)
        
        resultLabel = UILabel()
        resultLabel.font = .systemFont(ofSize: 18, weight: .bold)
        resultLabel.textAlignment = .center
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resultLabel)
        
        let signatureLabel = createSectionTitle("Signature")
        contentView.addSubview(signatureLabel)
        
        signatureTextView = createTextView()
        contentView.addSubview(signatureTextView)
        
        let signatureCopyBtn = createSmallButton(image: "doc.on.doc", title: "Copy")
        signatureCopyBtn.addTarget(self, action: #selector(copySignature), for: .touchUpInside)
        contentView.addSubview(signatureCopyBtn)
        
        let signatureShareBtn = createSmallButton(image: "square.and.arrow.up", title: "Share")
        signatureShareBtn.addTarget(self, action: #selector(shareSignature), for: .touchUpInside)
        contentView.addSubview(signatureShareBtn)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            keyLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            keyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            keyNameTextField.topAnchor.constraint(equalTo: keyLabel.bottomAnchor, constant: 12),
            keyNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            keyNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            keyNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            buttonStack.topAnchor.constraint(equalTo: keyNameTextField.bottomAnchor, constant: 12),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 50),
            
            savedKeysLabel.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 20),
            savedKeysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            savedKeysStackView.topAnchor.constraint(equalTo: savedKeysLabel.bottomAnchor, constant: 8),
            savedKeysStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            privateLabel.topAnchor.constraint(equalTo: savedKeysStackView.bottomAnchor, constant: 16),
            privateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            privateKeyTextView.topAnchor.constraint(equalTo: privateLabel.bottomAnchor, constant: 4),
            privateKeyTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            privateKeyTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            privateKeyTextView.heightAnchor.constraint(equalToConstant: 80),
            
            publicLabel.topAnchor.constraint(equalTo: privateKeyTextView.bottomAnchor, constant: 12),
            publicLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            publicKeyTextView.topAnchor.constraint(equalTo: publicLabel.bottomAnchor, constant: 4),
            publicKeyTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            publicKeyTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            publicKeyTextView.heightAnchor.constraint(equalToConstant: 80),
            
            divider1.topAnchor.constraint(equalTo: publicKeyTextView.bottomAnchor, constant: 20),
            divider1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            divider1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            divider1.heightAnchor.constraint(equalToConstant: 1),
            
            inputLabel.topAnchor.constraint(equalTo: divider1.bottomAnchor, constant: 20),
            inputLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            inputTextView.topAnchor.constraint(equalTo: inputLabel.bottomAnchor, constant: 12),
            inputTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            inputTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            inputTextView.heightAnchor.constraint(equalToConstant: 100),
            
            inputPasteBtn.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 8),
            inputPasteBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            inputPasteBtn.widthAnchor.constraint(equalToConstant: 100),
            inputPasteBtn.heightAnchor.constraint(equalToConstant: 36),
            
            actionStack.topAnchor.constraint(equalTo: inputPasteBtn.bottomAnchor, constant: 16),
            actionStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            actionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            actionStack.heightAnchor.constraint(equalToConstant: 50),
            
            resultLabel.topAnchor.constraint(equalTo: actionStack.bottomAnchor, constant: 12),
            resultLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            signatureLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
            signatureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            signatureTextView.topAnchor.constraint(equalTo: signatureLabel.bottomAnchor, constant: 12),
            signatureTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            signatureTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            signatureTextView.heightAnchor.constraint(equalToConstant: 100),
            
            signatureCopyBtn.topAnchor.constraint(equalTo: signatureTextView.bottomAnchor, constant: 8),
            signatureCopyBtn.trailingAnchor.constraint(equalTo: signatureShareBtn.leadingAnchor, constant: -8),
            signatureCopyBtn.widthAnchor.constraint(equalToConstant: 80),
            signatureCopyBtn.heightAnchor.constraint(equalToConstant: 36),
            
            signatureShareBtn.topAnchor.constraint(equalTo: signatureTextView.bottomAnchor, constant: 8),
            signatureShareBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            signatureShareBtn.widthAnchor.constraint(equalToConstant: 80),
            signatureShareBtn.heightAnchor.constraint(equalToConstant: 36),
            signatureShareBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            signatureTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
        ])
    }
    
    func createSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func createCaption(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func createTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.backgroundColor = .secondarySystemBackground
        tf.layer.cornerRadius = 12
        tf.font = .systemFont(ofSize: 16)
        
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftView = padding
        tf.leftViewMode = .always
        tf.rightView = padding
        tf.rightViewMode = .always
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }
    
    func createTextView() -> UITextView {
        let tv = UITextView()
        tv.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        tv.backgroundColor = .secondarySystemBackground
        tv.layer.cornerRadius = 12
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }
    
    func createHorizontalStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    func createButton(title: String, image: String, style: ButtonStyle) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setImage(UIImage(systemName: image), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        switch style {
        case .primary:
            btn.backgroundColor = .systemBlue
            btn.setTitleColor(.white, for: .normal)
            btn.tintColor = .white
        case .secondary:
            btn.backgroundColor = .secondarySystemBackground
            btn.setTitleColor(.label, for: .normal)
            btn.tintColor = .label
        case .success:
            btn.backgroundColor = .systemGreen
            btn.setTitleColor(.white, for: .normal)
            btn.tintColor = .white
        case .warning:
            btn.backgroundColor = .systemOrange
            btn.setTitleColor(.white, for: .normal)
            btn.tintColor = .white
        case .danger:
            btn.backgroundColor = .systemRed
            btn.setTitleColor(.white, for: .normal)
            btn.tintColor = .white
        }
        
        return btn
    }
    
    enum ButtonStyle {
        case primary, secondary, success, warning, danger
    }
    
    func createDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        return divider
    }
    
    func createSmallButton(image: String, title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: image), for: .normal)
        btn.setTitle(" \(title)", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.backgroundColor = .secondarySystemBackground
        btn.setTitleColor(.label, for: .normal)
        btn.tintColor = .label
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }
    
    func loadSavedKeys() {
        savedECKeys = KeychainHelper.listKeys(prefix: "CryptoApp_ECPrivate_")
        updateSavedKeysUI()
    }
    
    func updateSavedKeysUI() {
        savedKeysStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for name in savedECKeys {
            let btn = createButton(title: name, image: name == currentECKeyName ? "checkmark.circle.fill" : "key.fill", style: name == currentECKeyName ? .success : .secondary)
            btn.addTarget(self, action: #selector(loadKey(_:)), for: .touchUpInside)
            savedKeysStackView.addArrangedSubview(btn)
        }
    }
    
    @objc func generateKeypair() {
        let privateKey = P256.Signing.PrivateKey()
        privateKeyTextView.text = privateKey.pemRepresentation
        publicKeyTextView.text = privateKey.publicKey.pemRepresentation
    }
    
    @objc func saveKeys() {
        guard let keyName = keyNameTextField.text, !keyName.isEmpty,
              let privateKey = privateKeyTextView.text, !privateKey.isEmpty,
              let publicKey = publicKeyTextView.text, !publicKey.isEmpty else { return }
        
        KeychainHelper.saveKey(privateKey, forAccount: "CryptoApp_ECPrivate_\(keyName)")
        KeychainHelper.saveKey(publicKey, forAccount: "CryptoApp_ECPublic_\(keyName)")
        keyNameTextField.text = ""
        loadSavedKeys()
    }
    
    @objc func loadKey(_ sender: UIButton) {
        guard let name = sender.title(for: .normal) else { return }
        if let privateKey = KeychainHelper.loadKey(forAccount: "CryptoApp_ECPrivate_\(name)"),
           let publicKey = KeychainHelper.loadKey(forAccount: "CryptoApp_ECPublic_\(name)") {
            privateKeyTextView.text = privateKey
            publicKeyTextView.text = publicKey
            currentECKeyName = name
            updateSavedKeysUI()
        }
    }
    
    @objc func signText() {
        guard let privateKeyPEM = privateKeyTextView.text, !privateKeyPEM.isEmpty,
              let privateKey = try? P256.Signing.PrivateKey(pemRepresentation: privateKeyPEM),
              let data = inputTextView.text?.data(using: .utf8),
              let signature = try? privateKey.signature(for: data) else {
            resultLabel.text = "❌ Error signing"
            resultLabel.textColor = .systemRed
            return
        }
        
        signatureTextView.text = signature.derRepresentation.base64EncodedString()
        resultLabel.text = "✅ Signed!"
        resultLabel.textColor = .systemGreen
    }
    
    @objc func verifyText() {
        guard let publicKeyPEM = publicKeyTextView.text, !publicKeyPEM.isEmpty,
              let publicKey = try? P256.Signing.PublicKey(pemRepresentation: publicKeyPEM),
              let data = inputTextView.text?.data(using: .utf8),
              let sigData = Data(base64Encoded: signatureTextView.text ?? ""),
              let signature = try? P256.Signing.ECDSASignature(derRepresentation: sigData) else {
            resultLabel.text = "❌ Invalid data"
            resultLabel.textColor = .systemRed
            return
        }
        
        if publicKey.isValidSignature(signature, for: data) {
            resultLabel.text = "✅ Signature Valid!"
            resultLabel.textColor = .systemGreen
        } else {
            resultLabel.text = "❌ Signature Invalid"
            resultLabel.textColor = .systemRed
        }
    }
    
    @objc func pasteInput() {
        if let text = UIPasteboard.general.string {
            inputTextView.text = text
        }
    }
    
    @objc func copySignature() {
        if let text = signatureTextView.text, !text.isEmpty {
            UIPasteboard.general.string = text
        }
    }
    
    @objc func shareSignature() {
        guard let text = signatureTextView.text, !text.isEmpty else { return }
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}
