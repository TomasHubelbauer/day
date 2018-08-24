import UIKit

class Alerts {
    static func showError(_ viewController: UIViewController, _ message: String, fatal: Bool = false) {
        let alert = UIAlertController(title: "Day", message: message, preferredStyle: .alert)
        if !fatal {
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        }
        
        viewController.present(alert, animated: true)
    }
    
    static func askString(_ viewController: UIViewController, _ message: String, queue: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Day", message: message, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in textField.autocapitalizationType = .words })
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil ))
        alert.addAction(UIAlertAction(title: "Queue", style: .default, handler: { action in
            // Expect the text field to exist as we add it above
            if let item = alert.textFields!.first!.text {
                queue(item)
            }
        }))
        
        viewController.present(alert, animated: true)
    }
}
