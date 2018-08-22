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
            
            editButtonItem.action = #selector(onEnableEdit)
        } catch {
            // Construct an alert with no button so that the user has no choice but to exit the app
            let fatalAlert = UIAlertController(title: "Day", message: "Failed to load items", preferredStyle: .alert)
            self.present(fatalAlert, animated: true, completion: nil)
        }
    }
    
    @objc func onEnableEdit() {
        itemTableView.isEditing = true
        editButtonItem.title = "Done"
        editButtonItem.action = #selector(onDisableEdit)
        
        if itemTableView.isEditing {
            itemTableView.isEditing = false
            editButtonItem.title = "Edit"
        } else {
            
        }
    }
    
    @objc func onDisableEdit() {
        itemTableView.isEditing = false
        editButtonItem.title = "Edit"
        editButtonItem.action = #selector(onEnableEdit)
    }
}

// editorTextField
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if var text = textField.text {
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                if let items = items {
                    do {
                        let (section, item) = try items.add(section: "", item: text)
                        let indexPath = IndexPath(item: item, section: section)
                        itemTableView.insertRows(at: [indexPath], with: .automatic)
                        textField.text = ""
                    } catch {
                        // TODO: Telemetry
                        showError(error: error.localizedDescription)
                        return false
                    }
                } else {
                    // TODO: Telemetry
                    showError(error: "Cannot save; items failed to load")
                    return false
                }
            }
            
            textField.resignFirstResponder()
        }
        
        return true
    }
}

// itemsTableView

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Assume this works - no error handling
        let itemViewController =
            self.storyboard?.instantiateViewController(withIdentifier: "ItemViewController") as! ItemViewController
        if let items = items {
            // Must pass these as fields, cannot use init on the view controller: https://stackoverflow.com/a/27145059
            itemViewController.items = items
            itemViewController.indexPath = indexPath
            self.navigationController?.pushViewController(itemViewController, animated: true)
        }
    }
}

// itemsTableView
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let items = items {
            return items.getSectionCount()
        } else {
            // TODO: Telemetry
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = items {
            do {
                return try items.getSectionItemsCount(sectionIndex: section)
            } catch {
                // TODO: Telemetry
                return 0
            }
        } else {
            // TODO: Telemetry
            return 0
        }
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell")! // Assume success because we handle the name
        if let items = items {
            do {
                let item = try items.getItem(sectionIndex: indexPath.section, index: indexPath.row)
                cell.textLabel?.text = item
            } catch {
                // TODO: Telemetry
            }
        } else {
            // TODO: Telemetry
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let items = items {
            return items.getSectionName(index: section)
        } else {
            // TODO: Telemetry
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let items = items {
            if (editingStyle == .delete) {
                do {
                    let item = try items.getItem(sectionIndex: indexPath.section, index: indexPath.row)
                    let alert = UIAlertController(title: "Day", message: item, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Keep", style: UIAlertActionStyle.cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (alertAction:UIAlertAction!) in
                        do {
                            let _ = try items.removeItem(sectionIndex: indexPath.section, index: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        } catch {
                            self.showError(error: "Failed to remove")
                        }
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                } catch {
                    showError(error: "Failed to find the item")
                }
            } else {
                showError(error: "Unexpected editing stle \(editingStyle.rawValue)")
            }
        } else {
            showError(error: "Failed to load")
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let items = items {
            if let item = try? items.removeItem(sectionIndex: sourceIndexPath.section, index: sourceIndexPath.row) {
                do {
                    try items.insertItem(sectionIndex: destinationIndexPath.section, index: destinationIndexPath.row, item: item)
                } catch {
                    showError(error: "Failed to save")
                }
            } else {
                showError(error: "Not found: \(sourceIndexPath.section)-\(sourceIndexPath.row)")
            }
        } else {
            showError(error: "Failed to load")
        }
    }
}

// Error handling
extension ViewController {
    func showError(error: String) {
        let alert = UIAlertController(title: "Day", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
