import UIKit

class ItemViewController: UIViewController {
    @IBOutlet weak var itemLabel: UILabel!
    
    // Rely on this being set before the view controller is presented
    public var items: Items!
    public var indexPath: IndexPath!
    
    override func viewDidAppear(_ animated: Bool) {
       self.itemLabel.text = items.getItem(sectionIndex: indexPath.section, itemIndex: indexPath.row)
    }
}
