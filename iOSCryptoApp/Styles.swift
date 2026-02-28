import UIKit

extension UIButton {
    static func styled(title: String, systemImage: String? = nil, style: ButtonStyle = .primary) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        
        if let imageName = systemImage {
            btn.setImage(UIImage(systemName: imageName), for: .normal)
            btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        }
        
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.layer.cornerRadius = 12
        
        switch style {
        case .primary:
            btn.backgroundColor = .systemBlue
            btn.setTitleColor(.white, for: .normal)
            btn.tintColor = .white
        case .secondary:
            btn.backgroundColor = .systemGray5
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
}

extension UITextField {
    static func styled(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .none
        tf.backgroundColor = .secondarySystemBackground
        tf.layer.cornerRadius = 12
        tf.font = .systemFont(ofSize: 16)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.rightView = paddingView
        tf.rightViewMode = .always
        
        return tf
    }
}

extension UITextView {
    static func styled() -> UITextView {
        let tv = UITextView()
        tv.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        tv.backgroundColor = .secondarySystemBackground
        tv.layer.cornerRadius = 12
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return tv
    }
}

extension UILabel {
    static func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }
    
    static func caption(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }
}
