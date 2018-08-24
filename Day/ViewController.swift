import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var itemTableView: UITableView!

    private var items: Items?
    
    override func viewDidLoad() {
        do {
            items = try Items()
            itemTableView.dataSource = self
            itemTableView.delegate = self
        } catch {
            // Construct an alert with no button so that the user has no choice but to exit the app
            Alerts.showError(self, "Failed to load", fatal: true)
        }
    }

    @IBAction func composeButtonItemAction(_ sender: UIBarButtonItem) {
        Alerts.askQueue(self, queue: { item in
            if !item.isEmpty {
                if let items = self.items {
                    do {
                        let sectionIndex = try items.queueItem(section: "", item)
                        let indexPath = IndexPath(item: 0, section: sectionIndex)
                        self.itemTableView.insertRows(at: [indexPath], with: .automatic)
                    } catch {
                        // TODO: Send to telemetry (should not fail)
                        Alerts.showError(self, "Failed to queue")
                    }
                } else {
                    // TODO: Send to telemetry (should not happen)
                    Alerts.showError(self, "Failed to load", fatal: true)
                }
            }
        })
    }
    
    @IBAction func editButtonItemAction(_ sender: Any) {
        itemTableView.isEditing = !itemTableView.isEditing
        self.setEditing(itemTableView.isEditing, animated: true)
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
            itemViewController.tableView = itemTableView
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
                // Delete without asking here as the double tap in the editing mode serves as a prompt
                do {
                    let _ = try items.removeItem(sectionIndex: indexPath.section, itemIndex: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } catch {
                    // TODO: Send to telemetry (should not fail)
                    Alerts.showError(self, "Failed to remove")
                }
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
            Alerts.showError(self, "Failed to load", fatal: true)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let items = items {
            do {
                let item = try items.removeItem(sectionIndex: sourceIndexPath.section, itemIndex: sourceIndexPath.row)
                try items.insertItem(sectionIndex: destinationIndexPath.section, itemIndex: destinationIndexPath.row, item)
            } catch {
                // TODO: Send to telemetry (should not fail)
                Alerts.showError(self, "Failed to move")
            }
        } else {
            // TODO: Send to telemetry (should not happen)
            Alerts.showError(self, "Failed to load", fatal: true)
        }
    }
}
