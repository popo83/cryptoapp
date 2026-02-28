import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set icons for each tab
        if let items = tabBar.items {
            if items.count > 0 {
                items[0].image = UIImage(systemName: "lock.fill")
                items[0].title = "Encrypt"
            }
            if items.count > 1 {
                items[1].image = UIImage(systemName: "pencil")
                items[1].title = "Signature"
            }
            if items.count > 2 {
                items[2].image = UIImage(systemName: "doc.fill")
                items[2].title = "File"
            }
            if items.count > 3 {
                items[3].image = UIImage(systemName: "clock")
                items[3].title = "History"
            }
        }
    }
}
