import UIKit

class Alerts {
    static func showError(_ viewController: UIViewController, _ error: String, fatal: Bool = false) {
        let alert = UIAlertController(title: "Day", message: error, preferredStyle: .alert)
        if !fatal {
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        }
        
        viewController.present(alert, animated: true)
    }
    
    static func askQueue(_ viewController: UIViewController, queue: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Day", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in textField.autocapitalizationType = .sentences })
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil ))
        alert.addAction(UIAlertAction(title: "Queue", style: .default, handler: { action in
            // Expect the text field to exist as we add it above
            if let item = alert.textFields!.first!.text {
                queue(item)
            }
        }))
        
        viewController.present(alert, animated: true)
    }
    
    static func askDelete(_ viewController: UIViewController, _ item: String, delete: @escaping () -> Void) {
        let alert = UIAlertController(title: "Day", message: "Delete '\(item)'?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil ))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            delete()
        }))
        
        viewController.present(alert, animated: true)
    }
}
