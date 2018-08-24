import UIKit

class ItemViewController: UIViewController {
    @IBOutlet weak var itemTextView: UITextView!
    
    // Rely on this being set before the view controller is presented
    public var items: Items!
    public var indexPath: IndexPath!
    public var tableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        itemTextView.text = items.getItem(sectionIndex: indexPath.section, itemIndex: indexPath.row)
        itemTextView.delegate = self
        itemTextView.becomeFirstResponder()
    }

    @IBAction func trashButtonItemAction(_ sender: UIBarButtonItem) {
        let item = items.getItem(sectionIndex: indexPath.section, itemIndex: indexPath.row)
        Alerts.askDelete(self, item, delete: {
            do {
                let _ = try self.items.removeItem(sectionIndex: self.indexPath.section, itemIndex: self.indexPath.row)
                self.tableView.deleteRows(at: [self.indexPath], with: .none)
                // Assume `navigationController` is there because we give it value
                self.navigationController!.popViewController(animated: true)
            } catch {
                // TODO: Send to telemetry (should not fail)
                Alerts.showError(self, "Failed to remove")
            }
        })
    }
}

extension ItemViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        do {
            let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            try items.setItem(sectionIndex: indexPath.section, itemIndex: indexPath.row, text)
            tableView.reloadRows(at: [indexPath], with: .none)
        } catch {
            Alerts.showError(self, "Failed to edit")
        }
    }
}
