import UIKit

class Errors {
    static func show(_ viewController: UIViewController, _ error: String, fatal: Bool = false) {
        let alert = UIAlertController(title: "Day", message: error, preferredStyle: UIAlertControllerStyle.alert)
        if !fatal {
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        }
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
