import UIKit

class ItemViewController: UIViewController {
    @IBOutlet weak var itemLabel: UILabel!
    
    // Rely on this being set before the view controller is presented
    public var items: Items!
    public var indexPath: IndexPath!

    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        do {
            self.itemLabel.text = try items.getItem(sectionIndex: indexPath.section, index: indexPath.row)
        } catch {
            // TODO: Alert + telemetry
        }
    }
}
