import UIKit
import LocalAuthentication

class AuthenticationViewController: UIViewController {
    
    private let containerView = UIView()
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let faceIDButton = UIButton(type: .system)
    private let touchIDButton = UIButton(type: .system)
    private let errorLabel = UILabel()
    private var tapCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Secret: 5 taps on title to reset tutorial
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(titleTapped))
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func titleTapped() {
        tapCount += 1
        if tapCount >= 5 {
            tapCount = 0
            UserDefaults.standard.set(false, forKey: "tutorialCompleted")
            showTutorial()
        }
    }
    
    func showTutorial() {
        let tutorialVC = TutorialViewController()
        tutorialVC.modalPresentationStyle = .fullScreen
        present(tutorialVC, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authenticate()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Container
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Icon
        iconLabel.text = "🔒"
        iconLabel.font = .systemFont(ofSize: 80)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(iconLabel)
        
        // Title
        titleLabel.text = "CryptoApp"
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Authenticate to access"
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .gray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subtitleLabel)
        
        // Face ID Button
        faceIDButton.setTitle("  Sign in with Face ID", for: .normal)
        faceIDButton.setImage(UIImage(systemName: "faceid"), for: .normal)
        faceIDButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        faceIDButton.backgroundColor = .systemBlue
        faceIDButton.setTitleColor(.white, for: .normal)
        faceIDButton.tintColor = .white
        faceIDButton.layer.cornerRadius = 12
        faceIDButton.addTarget(self, action: #selector(authenticate), for: .touchUpInside)
        faceIDButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(faceIDButton)
        
        // Touch ID Button
        touchIDButton.setTitle("  Sign in with Touch ID", for: .normal)
        touchIDButton.setImage(UIImage(systemName: "touchid"), for: .normal)
        touchIDButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        touchIDButton.backgroundColor = .systemGray5
        touchIDButton.setTitleColor(.systemBlue, for: .normal)
        touchIDButton.tintColor = .systemBlue
        touchIDButton.layer.cornerRadius = 12
        touchIDButton.addTarget(self, action: #selector(authenticate), for: .touchUpInside)
        touchIDButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(touchIDButton)
        
        // Error Label
        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.textColor = .red
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(errorLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            iconLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            faceIDButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            faceIDButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            faceIDButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            faceIDButton.heightAnchor.constraint(equalToConstant: 50),
            
            touchIDButton.topAnchor.constraint(equalTo: faceIDButton.bottomAnchor, constant: 12),
            touchIDButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            touchIDButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            touchIDButton.heightAnchor.constraint(equalToConstant: 50),
            
            errorLabel.topAnchor.constraint(equalTo: touchIDButton.bottomAnchor, constant: 20),
            errorLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }
    
    @objc func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access CryptoApp"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authError in
                DispatchQueue.main.async {
                    if success {
                        self?.showMainApp()
                    } else {
                        self?.showError("Authentication failed")
                    }
                }
            }
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Authenticate to access CryptoApp"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, authError in
                DispatchQueue.main.async {
                    if success {
                        self?.showMainApp()
                    } else {
                        self?.showError("Authentication failed")
                    }
                }
            }
        } else {
            // No biometric available, show main app directly
            showMainApp()
        }
    }
    
    func showMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
}
