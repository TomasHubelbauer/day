import UIKit

class ItemViewController: UIViewController {
    @IBOutlet weak var itemTextView: UITextView!
    
    // Rely on this being set before the view controller is presented
    public var items: Items!
    public var indexPath: IndexPath!
    public var reloadInList: (() -> Void)!
    
    override func viewDidAppear(_ animated: Bool) {
        itemTextView.text = items.getItem(sectionIndex: indexPath.section, itemIndex: indexPath.row)
        itemTextView.delegate = self
        itemTextView.becomeFirstResponder()
    }
}

extension ItemViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        do {
            try items.setItem(sectionIndex: indexPath.section, itemIndex: indexPath.row, textView.text ?? "")
            reloadInList()
        } catch {
            Alerts.showError(self, "Failed to edit")
        }
    }
}
