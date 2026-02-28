import UIKit
import UniformTypeIdentifiers
import CryptoKit

class FileViewController: UIViewController, UIDocumentPickerDelegate {
    
    var scrollView: UIScrollView!
    var contentView: UIView!
    
    var keyNameTextField: UITextField!
    var keyTextField: UITextField!
    var fileLabel: UILabel!
    var savedKeysStackView: UIStackView!
    var selectedFileURL: URL?
    
    var savedKeyNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "File"
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
        
        let keyLabel = createSectionTitle("AES Key")
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
        
        let savedKeysLabel = createCaption("Your keys:")
        contentView.addSubview(savedKeysLabel)
        
        savedKeysStackView = createHorizontalStack()
        contentView.addSubview(savedKeysStackView)
        
        let divider1 = createDivider()
        contentView.addSubview(divider1)
        
        let fileSectionLabel = createSectionTitle("File Encryption")
        contentView.addSubview(fileSectionLabel)
        
        let selectBtn = createButton(title: "Select File", image: "doc.badge.plus", style: .primary)
        selectBtn.addTarget(self, action: #selector(selectFile), for: .touchUpInside)
        contentView.addSubview(selectBtn)
        
        fileLabel = UILabel()
        fileLabel.text = "No file selected"
        fileLabel.font = .systemFont(ofSize: 16)
        fileLabel.textColor = .secondaryLabel
        fileLabel.textAlignment = .center
        fileLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(fileLabel)
        
        let actionStack = createHorizontalStack()
        contentView.addSubview(actionStack)
        
        let encryptBtn = createButton(title: "Encrypt", image: "lock.fill", style: .success)
        encryptBtn.addTarget(self, action: #selector(encryptFile), for: .touchUpInside)
        actionStack.addArrangedSubview(encryptBtn)
        
        let decryptBtn = createButton(title: "Decrypt", image: "lock.open.fill", style: .warning)
        decryptBtn.addTarget(self, action: #selector(decryptFile), for: .touchUpInside)
        actionStack.addArrangedSubview(decryptBtn)
        
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
            
            buttonStack.topAnchor.constraint(equalTo: keyTextField.bottomAnchor, constant: 12),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 50),
            
            savedKeysLabel.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 20),
            savedKeysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            savedKeysStackView.topAnchor.constraint(equalTo: savedKeysLabel.bottomAnchor, constant: 8),
            savedKeysStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            divider1.topAnchor.constraint(equalTo: savedKeysStackView.bottomAnchor, constant: 24),
            divider1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            divider1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            divider1.heightAnchor.constraint(equalToConstant: 1),
            
            fileSectionLabel.topAnchor.constraint(equalTo: divider1.bottomAnchor, constant: 24),
            fileSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            selectBtn.topAnchor.constraint(equalTo: fileSectionLabel.bottomAnchor, constant: 16),
            selectBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            selectBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            selectBtn.heightAnchor.constraint(equalToConstant: 50),
            
            fileLabel.topAnchor.constraint(equalTo: selectBtn.bottomAnchor, constant: 16),
            fileLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fileLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            actionStack.topAnchor.constraint(equalTo: fileLabel.bottomAnchor, constant: 24),
            actionStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            actionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            actionStack.heightAnchor.constraint(equalToConstant: 50),
            actionStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
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
    
    func loadSavedKeys() {
        savedKeyNames = KeychainHelper.listKeys(prefix: "CryptoApp_AES_")
        updateSavedKeysUI()
    }
    
    func updateSavedKeysUI() {
        savedKeysStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for name in savedKeyNames {
            let btn = createButton(title: name, image: "key.fill", style: .secondary)
            btn.addTarget(self, action: #selector(loadKey(_:)), for: .touchUpInside)
            savedKeysStackView.addArrangedSubview(btn)
        }
    }
    
    @objc func generateKey() {
        keyTextField.text = CryptoAES.generateKey()
    }
    
    @objc func saveKey() {
        guard let keyName = keyNameTextField.text, !keyName.isEmpty,
              let key = keyTextField.text, !key.isEmpty else { return }
        KeychainHelper.saveKey(key, forAccount: "CryptoApp_AES_\(keyName)")
        keyNameTextField.text = ""
        loadSavedKeys()
    }
    
    @objc func loadKey(_ sender: UIButton) {
        guard let name = sender.title(for: .normal),
              let key = KeychainHelper.loadKey(forAccount: "CryptoApp_AES_\(name)") else { return }
        keyTextField.text = key
    }
    
    @objc func selectFile() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        selectedFileURL = url
        fileLabel.text = url.lastPathComponent
        fileLabel.textColor = .label
    }
    
    @objc func encryptFile() {
        guard let url = selectedFileURL, let key = keyTextField.text, !key.isEmpty else {
            showAlert(title: "Error", message: "Select file and key")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            guard let keyData = Data(base64Encoded: key) else { return }
            let symmetricKey = SymmetricKey(data: keyData)
            let sealedBox = try AES.GCM.seal(data, using: symmetricKey)
            guard let combined = sealedBox.combined else { return }
            
            let outURL = url.deletingPathExtension().appendingPathExtension("enc")
            try combined.write(to: outURL)
            showAlert(title: "Success", message: "File encrypted:\n\(outURL.lastPathComponent)")
        } catch {
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    @objc func decryptFile() {
        guard let url = selectedFileURL, let key = keyTextField.text, !key.isEmpty else {
            showAlert(title: "Error", message: "Select file and key")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            guard let keyData = Data(base64Encoded: key) else { return }
            let symmetricKey = SymmetricKey(data: keyData)
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decrypted = try AES.GCM.open(sealedBox, using: symmetricKey)
            
            let outURL = url.deletingPathExtension().appendingPathExtension("dec")
            try decrypted.write(to: outURL)
            showAlert(title: "Success", message: "File decrypted:\n\(outURL.lastPathComponent)")
        } catch {
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
