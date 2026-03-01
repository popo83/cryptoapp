import UIKit

class TutorialViewController: UIViewController {
    
    var pageControl: UIPageControl!
    var scrollView: UIScrollView!
    var nextButton: UIButton!
    var skipButton: UIButton!
    
    var pages: [(title: String, description: String, icon: String)] = [
        ("🔐 Generate Key", "Tap 'Generate' to create a new encryption key. Give it a name and save it securely in your device.", "wand.and.stars"),
        ("🔒 Encrypt", "Enter your text, select your key, then tap 'Encrypt'. Share or copy the encrypted result.", "lock.fill"),
        ("✍️ Digital Signature", "Create a key pair: Private Key (keep secret) + Public Key (share). Sign messages with your private key. Others verify with your public key.", "signature"),
        ("📁 Files", "Encrypt and decrypt files securely. Files are processed locally on your device.", "doc.fill"),
        ("🔑 Security", "Your keys are stored securely in the iOS Keychain. Face ID/Touch ID protects access.", "faceid")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    func setupUI() {
        // ScrollView
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Page Control
        pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .systemGray4
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        // Next Button
        nextButton = UIButton(type: .system)
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        nextButton.backgroundColor = .systemBlue
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 12
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        
        // Skip Button
        skipButton = UIButton(type: .system)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.titleLabel?.font = .systemFont(ofSize: 16)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skipButton)
        
        // Create pages
        for (index, page) in pages.enumerated() {
            let pageView = createPageView(title: page.title, description: page.description, icon: page.icon)
            pageView.frame = CGRect(x: CGFloat(index) * view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height - 200)
            scrollView.addSubview(pageView)
        }
        
        scrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(pages.count), height: view.bounds.height - 200)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -12),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    func createPageView(title: String, description: String, icon: String) -> UIView {
        let container = UIView()
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iconImageView)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = .systemFont(ofSize: 17)
        descLabel.textColor = .secondaryLabel
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -100),
            iconImageView.widthAnchor.constraint(equalToConstant: 100),
            iconImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 40),
            descLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -40)
        ])
        
        return container
    }
    
    @objc func nextTapped() {
        if pageControl.currentPage < pages.count - 1 {
            pageControl.currentPage += 1
            let x = CGFloat(pageControl.currentPage) * scrollView.bounds.width
            scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            updateButton()
        } else {
            finishTutorial()
        }
    }
    
    @objc func skipTapped() {
        finishTutorial()
    }
    
    func updateButton() {
        if pageControl.currentPage == pages.count - 1 {
            nextButton.setTitle("Get Started", for: .normal)
            skipButton.isHidden = true
        } else {
            nextButton.setTitle("Next", for: .normal)
            skipButton.isHidden = false
        }
    }
    
    func finishTutorial() {
        UserDefaults.standard.set(true, forKey: "tutorialCompleted")
        
        // Dismiss tutorial and show auth
        let authVC = AuthenticationViewController()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = authVC
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
}

extension TutorialViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        updateButton()
    }
}
