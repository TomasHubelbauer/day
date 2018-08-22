import UIKit

class ItemViewController: UIViewController {
    @IBOutlet weak var itemLabel: UILabel!
    
    public var item: String?

    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.itemLabel.text = item
    }
}
