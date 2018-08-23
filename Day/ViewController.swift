import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var editorTextField: UITextField!
    @IBOutlet weak var itemTableView: UITableView!

    private var items: Items?
    
    override func viewDidLoad() {
        do {
            items = try Items()
            
            editorTextField.delegate = self
            editorTextField.becomeFirstResponder()
            
            itemTableView.dataSource = self
            itemTableView.delegate = self
            
            editButtonItem.action = #selector(onToggleEdit)
        } catch {
            // Construct an alert with no button so that the user has no choice but to exit the app
            showError("Failed to load", fatal: true)
        }
    }
    
    @objc func onToggleEdit() {
        itemTableView.isEditing = !itemTableView.isEditing
        editButtonItem.title = itemTableView.isEditing ? "Done" : "Edit"
    }
    
    func showError(_ error: String, fatal: Bool = false) {
        let alert = UIAlertController(title: "Day", message: error, preferredStyle: UIAlertControllerStyle.alert)
        if !fatal {
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        }

        self.present(alert, animated: true, completion: nil)
    }
}

// editorTextField UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if var text = textField.text {
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                if let items = items {
                    do {
                        let sectionIndex = try items.queueItem(section: "", text)
                        let indexPath = IndexPath(item: 0, section: sectionIndex)
                        itemTableView.insertRows(at: [indexPath], with: .automatic)
                        textField.text = ""
                    } catch {
                        // TODO: Send to telemetry (should not fail)
                        showError("Failed to queue")
                        return false
                    }
                } else {
                    // TODO: Send to telemetry (should not happen)
                    showError("Failed to load", fatal: true)
                    return false
                }
            }
            
            textField.resignFirstResponder()
        }
        
        return true
    }
}

// itemsTableView UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Assume this works - we have the story board
        let storyboard = self.storyboard!
        // Assume this works - we control the identified and view controller
        let itemViewController = storyboard.instantiateViewController(withIdentifier: "ItemViewController") as! ItemViewController
        if let items = items {
            // Pass these as fields as we cannot use init on the view controller: https://stackoverflow.com/a/27145059
            itemViewController.items = items
            itemViewController.indexPath = indexPath
            // Assume this works - we control the storyboard
            let navigationController = self.navigationController!
            navigationController.pushViewController(itemViewController, animated: true)
        }
    }
}

// itemsTableView UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let items = items {
            return items.getCount()
        } else {
            // TODO: Send to telemetry (should not happen)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = items {
            return items.getCount(sectionIndex: section)
        } else {
            // TODO: Send to telemetry (should not happen)
            return 0
        }
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Assume this works - we handle the identifier and template
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell")!
        if let items = items {
            // Assume `textLabel` is there - we control the template
            let textLabel = cell.textLabel!
            textLabel.text = items.getItem(sectionIndex: indexPath.section, itemIndex: indexPath.row)
        } else {
            // TODO: Send to telemetry (should not happen)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let items = items {
            return items.getName(sectionIndex: section)
        } else {
            // TODO: Send to telemetry (should not happen)
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // TODO: Introduce non-editable + buttons at the end of each section
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // TODO: Introduce non-movable + buttons at the end of each section
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let items = items {
            switch editingStyle {
            case .delete: do {
                let item = items.getItem(sectionIndex: indexPath.section, itemIndex: indexPath.row)
                let alert = UIAlertController(title: "Day", message: item, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Keep", style: UIAlertActionStyle.cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (alertAction:UIAlertAction!) in
                    do {
                        let _ = try items.removeItem(sectionIndex: indexPath.section, itemIndex: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    } catch {
                        // TODO: Send to telemetry (should not fail)
                        self.showError("Failed to remove")
                    }
                }))
                
                self.present(alert, animated: true, completion: nil)
                }
            case .insert: do {
                // TODO: Send to telemetry (upcoming feature)
                }
            case .none: do {
                // TODO: Send to telemetry (when does this happen?)
                }
            }
        } else {
            // TODO: Send to telemetry (should not happen)
            showError("Failed to load", fatal: true)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let items = items {
            do {
                let item = try items.removeItem(sectionIndex: sourceIndexPath.section, itemIndex: sourceIndexPath.row)
                try items.insertItem(sectionIndex: destinationIndexPath.section, itemIndex: destinationIndexPath.row, item)
            } catch {
                // TODO: Send to telemetry (should not fail)
                showError("Failed to move")
            }
        } else {
            // TODO: Send to telemetry (should not happen)
            showError("Failed to load", fatal: true)
        }
    }
}
