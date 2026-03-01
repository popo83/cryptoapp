import UIKit
import CryptoKit

class EncryptViewController: UIViewController {
    
    var scrollView: UIScrollView!
    var contentView: UIView!
    
    var keyNameTextField: UITextField!
    var keyTextField: UITextField!
    var inputTextView: UITextView!
    var outputTextView: UITextView!
    var savedKeysLabel: UILabel!
    var savedKeysStackView: UIStackView!
    
    var savedKeyNames: [String] = []
    var currentKeyName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Encrypt"
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
        
        // Key Management Section
        let keyLabel = createSectionTitle("Key Management")
        contentView.addSubview(keyLabel)
        
        keyNameTextField = createTextField(placeholder: "Key name")
        contentView.addSubview(keyNameTextField)
        
        keyTextField = createTextField(placeholder: "Key (Base64)")
        keyTextField.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        contentView.addSubview(keyTextField)
        
        let buttonStack = createHorizontalStack()
        contentView.addSubview(buttonStack)
        
        let generateBtn = createButton(title: "Generate", image: "wand.and.stars", style: .primary)
        generateBtn.addTarget(self, action: #selector(generateKey), for: .touchUpInside)
        buttonStack.addArrangedSubview(generateBtn)
        
        let saveBtn = createButton(title: "Save", image: "square.and.arrow.down", style: .success)
        saveBtn.addTarget(self, action: #selector(saveKey), for: .touchUpInside)
        buttonStack.addArrangedSubview(saveBtn)
        
        savedKeysLabel = createCaption("Your keys:")
        contentView.addSubview(savedKeysLabel)
        
        savedKeysStackView = createHorizontalStack()
        contentView.addSubview(savedKeysStackView)
        
        let divider1 = createDivider()
        contentView.addSubview(divider1)
        
        let inputLabel = createSectionTitle("Text to encrypt")
        contentView.addSubview(inputLabel)
        
        inputTextView = createTextView()
        contentView.addSubview(inputTextView)
        
        // Paste button for input
        let pasteBtn = createSmallButton(image: "doc.on.clipboard", title: "Paste")
        pasteBtn.addTarget(self, action: #selector(pasteInput), for: .touchUpInside)
        contentView.addSubview(pasteBtn)
        
        let actionStack = createHorizontalStack()
        contentView.addSubview(actionStack)
        
        let encryptBtn = createButton(title: "Encrypt", image: "lock.fill", style: .success)
        encryptBtn.addTarget(self, action: #selector(encryptText), for: .touchUpInside)
        actionStack.addArrangedSubview(encryptBtn)
        
        let decryptBtn = createButton(title: "Decrypt", image: "lock.open.fill", style: .warning)
        decryptBtn.addTarget(self, action: #selector(decryptText), for: .touchUpInside)
        actionStack.addArrangedSubview(decryptBtn)
        
        let outputLabel = createSectionTitle("Result")
        contentView.addSubview(outputLabel)
        
        outputTextView = createTextView()
        outputTextView.isEditable = false
        contentView.addSubview(outputTextView)
        
        // Copy button for output
        let copyBtn = createSmallButton(image: "doc.on.doc", title: "Copy")
        copyBtn.addTarget(self, action: #selector(copyOutput), for: .touchUpInside)
        contentView.addSubview(copyBtn)
        
        let shareBtn = createButton(title: "Share", image: "square.and.arrow.up", style: .primary)
        shareBtn.addTarget(self, action: #selector(shareOutput), for: .touchUpInside)
        contentView.addSubview(shareBtn)
        
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
            
            keyTextField.topAnchor.constraint(equalTo: keyNameTextField.bottomAnchor, constant: 12),
            keyTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            keyTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            keyTextField.heightAnchor.constraint(equalToConstant: 50),
            
            buttonStack.topAnchor.constraint(equalTo: keyTextField.bottomAnchor, constant: 16),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 50),
            
            savedKeysLabel.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 20),
            savedKeysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            savedKeysStackView.topAnchor.constraint(equalTo: savedKeysLabel.bottomAnchor, constant: 8),
            savedKeysStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            divider1.topAnchor.constraint(equalTo: savedKeysStackView.bottomAnchor, constant: 20),
            divider1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            divider1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            divider1.heightAnchor.constraint(equalToConstant: 1),
            
            inputLabel.topAnchor.constraint(equalTo: divider1.bottomAnchor, constant: 20),
            inputLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            inputTextView.topAnchor.constraint(equalTo: inputLabel.bottomAnchor, constant: 12),
            inputTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            inputTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            inputTextView.heightAnchor.constraint(equalToConstant: 120),
            
            pasteBtn.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 8),
            pasteBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            pasteBtn.widthAnchor.constraint(equalToConstant: 100),
            pasteBtn.heightAnchor.constraint(equalToConstant: 36),
            
            actionStack.topAnchor.constraint(equalTo: pasteBtn.bottomAnchor, constant: 16),
            actionStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            actionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            actionStack.heightAnchor.constraint(equalToConstant: 50),
            
            outputLabel.topAnchor.constraint(equalTo: actionStack.bottomAnchor, constant: 24),
            outputLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            outputTextView.topAnchor.constraint(equalTo: outputLabel.bottomAnchor, constant: 12),
            outputTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            outputTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            outputTextView.heightAnchor.constraint(equalToConstant: 150),
            
            copyBtn.topAnchor.constraint(equalTo: outputTextView.bottomAnchor, constant: 8),
            copyBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            copyBtn.widthAnchor.constraint(equalToConstant: 100),
            copyBtn.heightAnchor.constraint(equalToConstant: 36),
            
            shareBtn.topAnchor.constraint(equalTo: copyBtn.bottomAnchor, constant: 16),
            shareBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            shareBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            shareBtn.heightAnchor.constraint(equalToConstant: 50),
            shareBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
        ])
    }
    
    // MARK: - UI Helpers
    
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
        tv.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
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
    
    // MARK: - Actions
    
    func loadSavedKeys() {
        savedKeyNames = KeychainHelper.listKeys(prefix: "CryptoApp_AES_")
        updateSavedKeysUI()
    }
    
    func updateSavedKeysUI() {
        savedKeysStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for name in savedKeyNames {
            let btn = createButton(title: name, image: name == currentKeyName ? "checkmark.circle.fill" : "key.fill", style: name == currentKeyName ? .success : .secondary)
            btn.addTarget(self, action: #selector(loadKey(_:)), for: .touchUpInside)
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(deleteKey(_:)))
            btn.addGestureRecognizer(longPress)
            
            savedKeysStackView.addArrangedSubview(btn)
        }
    }
    
    @objc func generateKey() {
        let key = CryptoAES.generateKey()
        keyTextField.text = key
    }
    
    @objc func saveKey() {
        guard let keyName = keyNameTextField.text, !keyName.isEmpty,
              let key = keyTextField.text, !key.isEmpty else { return }
        KeychainHelper.saveKey(key, forAccount: "CryptoApp_AES_\(keyName)")
        keyNameTextField.text = ""
        loadSavedKeys()
    }
    
    @objc func loadKey(_ sender: UIButton) {
        guard let name = sender.title(for: .normal) else { return }
        if let key = KeychainHelper.loadKey(forAccount: "CryptoApp_AES_\(name)") {
            keyTextField.text = key
            currentKeyName = name
            updateSavedKeysUI()
        }
    }
    
    @objc func deleteKey(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let btn = gesture.view as? UIButton, let name = btn.title(for: .normal) else { return }
        
        let alert = UIAlertController(title: "Delete Key", message: "Delete '\(name)'?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            KeychainHelper.deleteKeys(prefix: "CryptoApp_AES_", name: name)
            if self?.currentKeyName == name {
                self?.currentKeyName = nil
                self?.keyTextField.text = ""
            }
            self?.loadSavedKeys()
        })
        present(alert, animated: true)
    }
    
    @objc func pasteInput() {
        if let text = UIPasteboard.general.string {
            inputTextView.text = text
        }
    }
    
    @objc func copyOutput() {
        if let text = outputTextView.text, !text.isEmpty {
            UIPasteboard.general.string = text
        }
    }
    
    @objc func encryptText() {
        guard let key = keyTextField.text, !key.isEmpty,
              let text = inputTextView.text, !text.isEmpty else { return }
        
        do {
            outputTextView.text = try CryptoAES.encrypt(text, key: key)
        } catch {
            outputTextView.text = "Error: \(error.localizedDescription)"
        }
    }
    
    @objc func decryptText() {
        guard let key = keyTextField.text, !key.isEmpty,
              let text = inputTextView.text, !text.isEmpty else { return }
        
        do {
            outputTextView.text = try CryptoAES.decrypt(text, key: key)
        } catch {
            outputTextView.text = "Error: \(error.localizedDescription)"
        }
    }
    
    @objc func shareOutput() {
        guard let text = outputTextView.text, !text.isEmpty else { return }
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}
