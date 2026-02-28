import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var history: [HistoryItem] = []
    var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "History"
        view.backgroundColor = .systemBackground
        setupUI()
        loadHistory()
    }
    
    func setupUI() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        emptyLabel = UILabel()
        emptyLabel.text = "No operations yet"
        emptyLabel.font = .systemFont(ofSize: 18)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        
        let clearBtn = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearHistory))
        clearBtn.tintColor = .systemRed
        navigationItem.rightBarButtonItem = clearBtn
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "CryptoHistory"),
           let saved = try? JSONDecoder().decode([HistoryItem].self, from: data) {
            history = saved
        }
        emptyLabel.isHidden = !history.isEmpty
        tableView.reloadData()
    }
    
    @objc func clearHistory() {
        let alert = UIAlertController(title: "Clear History", message: "Delete all history?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            self?.history.removeAll()
            UserDefaults.standard.removeObject(forKey: "CryptoHistory")
            self?.emptyLabel.isHidden = false
            self?.tableView.reloadData()
        })
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let item = history[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        content.text = "\(item.operation)"
        content.secondaryText = "\(formatter.string(from: item.date))\n\(item.input.prefix(25))..."
        content.secondaryTextProperties.numberOfLines = 2
        content.secondaryTextProperties.font = .systemFont(ofSize: 13)
        content.secondaryTextProperties.color = .secondaryLabel
        
        content.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = history[indexPath.row]
        
        let alert = UIAlertController(title: item.operation, message: "Input:\n\(item.input)\n\nOutput:\n\(item.output)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Copy Output", style: .default) { _ in
            UIPasteboard.general.string = item.output
        })
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            history.remove(at: indexPath.row)
            if let data = try? JSONEncoder().encode(history) {
                UserDefaults.standard.set(data, forKey: "CryptoHistory")
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            emptyLabel.isHidden = !history.isEmpty
        }
    }
}
