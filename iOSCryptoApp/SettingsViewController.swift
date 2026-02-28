import UIKit

class SettingsViewController: UIViewController {
    
    var scrollView: UIScrollView!
    var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        setupUI()
        
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
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Appearance Section
        let appearanceLabel = createSectionTitle("Appearance")
        contentView.addSubview(appearanceLabel)
        
        let themeCard = createCard()
        contentView.addSubview(themeCard)
        
        let themeLabel = UILabel()
        themeLabel.text = "Theme"
        themeLabel.font = .systemFont(ofSize: 16, weight: .medium)
        themeCard.addSubview(themeLabel)
        
        let themeSwitch = UISwitch()
        themeSwitch.isOn = traitCollection.userInterfaceStyle == .dark
        themeSwitch.addTarget(self, action: #selector(themeSwitchChanged(_:)), for: .valueChanged)
        themeCard.addSubview(themeSwitch)
        
        let themeDescLabel = UILabel()
        themeDescLabel.text = "Dark Mode"
        themeDescLabel.font = .systemFont(ofSize: 13)
        themeDescLabel.textColor = .secondaryLabel
        themeCard.addSubview(themeDescLabel)
        
        // Tutorial Section
        let tutorialLabel = createSectionTitle("Help")
        contentView.addSubview(tutorialLabel)
        
        let tutorialCard = createCard()
        contentView.addSubview(tutorialCard)
        
        let restartTutorialBtn = createButton(title: "Restart Tutorial", icon: "questionmark.circle", style: .primary)
        restartTutorialBtn.addTarget(self, action: #selector(restartTutorial), for: .touchUpInside)
        tutorialCard.addSubview(restartTutorialBtn)
        
        // History Section
        let historyLabel = createSectionTitle("History")
        contentView.addSubview(historyLabel)
        
        let historyCard = createCard()
        contentView.addSubview(historyCard)
        
        let historyTableView = UITableView()
        historyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.isScrollEnabled = false
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        historyCard.addSubview(historyTableView)
        
        // Layout
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
            
            appearanceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            appearanceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            themeCard.topAnchor.constraint(equalTo: appearanceLabel.bottomAnchor, constant: 12),
            themeCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            themeCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            themeCard.heightAnchor.constraint(equalToConstant: 80),
            
            themeLabel.topAnchor.constraint(equalTo: themeCard.topAnchor, constant: 12),
            themeLabel.leadingAnchor.constraint(equalTo: themeCard.leadingAnchor, constant: 16),
            
            themeSwitch.centerYAnchor.constraint(equalTo: themeCard.centerYAnchor),
            themeSwitch.trailingAnchor.constraint(equalTo: themeCard.trailingAnchor, constant: -16),
            
            themeDescLabel.topAnchor.constraint(equalTo: themeLabel.bottomAnchor, constant: 4),
            themeDescLabel.leadingAnchor.constraint(equalTo: themeCard.leadingAnchor, constant: 16),
            
            tutorialLabel.topAnchor.constraint(equalTo: themeCard.bottomAnchor, constant: 24),
            tutorialLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            tutorialCard.topAnchor.constraint(equalTo: tutorialLabel.bottomAnchor, constant: 12),
            tutorialCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tutorialCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tutorialCard.heightAnchor.constraint(equalToConstant: 50),
            
            restartTutorialBtn.topAnchor.constraint(equalTo: tutorialCard.topAnchor),
            restartTutorialBtn.leadingAnchor.constraint(equalTo: tutorialCard.leadingAnchor),
            restartTutorialBtn.trailingAnchor.constraint(equalTo: tutorialCard.trailingAnchor),
            restartTutorialBtn.bottomAnchor.constraint(equalTo: tutorialCard.bottomAnchor),
            
            historyLabel.topAnchor.constraint(equalTo: tutorialCard.bottomAnchor, constant: 24),
            historyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            historyCard.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 12),
            historyCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            historyCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            historyCard.heightAnchor.constraint(equalToConstant: 200),
            historyCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            historyTableView.topAnchor.constraint(equalTo: historyCard.topAnchor),
            historyTableView.leadingAnchor.constraint(equalTo: historyCard.leadingAnchor),
            historyTableView.trailingAnchor.constraint(equalTo: historyCard.trailingAnchor),
            historyTableView.bottomAnchor.constraint(equalTo: historyCard.bottomAnchor)
        ])
        
        // Store reference for reload
        self.historyTableView = historyTableView
    }
    
    var historyTableView: UITableView!
    var historyItems: [String] = []
    
    func loadHistory() {
        historyItems = KeychainHelper.listKeys(prefix: "CryptoApp_History_").reversed()
        historyTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadHistory()
    }
    
    @objc func themeSwitchChanged(_ sender: UISwitch) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        window.overrideUserInterfaceStyle = sender.isOn ? .dark : .light
    }
    
    @objc func restartTutorial() {
        UserDefaults.standard.set(false, forKey: "tutorialCompleted")
        
        let tutorialVC = TutorialViewController()
        tutorialVC.modalPresentationStyle = .fullScreen
        present(tutorialVC, animated: true)
    }
    
    func createSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func createCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }
    
    func createButton(title: String, icon: String, style: ButtonStyle) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setImage(UIImage(systemName: icon), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        switch style {
        case .primary:
            btn.setTitleColor(.systemBlue, for: .normal)
            btn.tintColor = .systemBlue
        case .danger:
            btn.setTitleColor(.systemRed, for: .normal)
            btn.tintColor = .systemRed
        }
        
        return btn
    }
    
    enum ButtonStyle {
        case primary, danger
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        cell.textLabel?.text = historyItems[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 14)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
