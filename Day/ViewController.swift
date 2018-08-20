import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var editorTextField: UITextField!
    @IBOutlet weak var editSwitch: UISwitch!
    @IBOutlet weak var itemTableView: UITableView!
    
    typealias Data = [String : [String]]
    
    private var data: Data!
    
    override func viewDidLoad() {
        data = loadData()
        editorTextField.delegate = self
        editSwitch.addTarget(self, action: #selector(onToggleEditMode), for: .valueChanged)
        itemTableView.dataSource = self
    }
    
    @objc func onToggleEditMode() {
        itemTableView.isEditing = !itemTableView.isEditing
    }
    
    override func viewDidAppear(_ animated: Bool) {
        editorTextField.becomeFirstResponder()
    }
}

// editorTextField
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if var text = textField.text {
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                data[""] = [text] + (data[""] ?? [])
                saveData(data: data)
                self.itemTableView.reloadData()
            }
            
            textField.text = ""
            textField.resignFirstResponder()
        }
        
        return true
    }
}

// itemsTableView
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = data[Array(data.keys)[section]]!
        return array.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell")!
        let text = data[Array(data.keys)[indexPath.section]]![indexPath.row]
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(data.keys)[section]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let key = Array(data.keys)[indexPath.section]
            var array = data[key]!
            let item = array[indexPath.row]
            let alert = UIAlertController(title: "Day", message: item, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Keep", style: UIAlertActionStyle.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (alertAction:UIAlertAction!) in
                array.remove(at: indexPath.row)
                self.data[key] = array
                self.saveData(data: self.data)
                self.data = self.loadData()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceKey = Array(data.keys)[sourceIndexPath.section]
        var sourceArray = data[sourceKey]!
        let item = sourceArray[sourceIndexPath.row]
        sourceArray.remove(at: sourceIndexPath.row)
        data[sourceKey] = sourceArray

        let destinationKey = Array(data.keys)[destinationIndexPath.section]
        var destinationArray = data[destinationKey]!
        destinationArray.insert(item, at: destinationIndexPath.row)
        data[destinationKey] = destinationArray
        
        saveData(data: data)
        data = loadData()
        tableView.reloadData()
    }
}

// Data management
extension ViewController {
    func saveData(data: Data) {
        if let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dataFileUrl = documentsDirectoryUrl.appendingPathComponent("data.txt")
            do {
                var contents = ""
                for (section, items) in data {
                    contents.append("[" + section + "]\n")
                    for item in items {
                        contents.append(item + "\n")
                    }
                }
                
                try contents.write(to: dataFileUrl, atomically: false, encoding: .utf8)
            } catch {
                showError(error: "Failed to initialize the data file")
            }
        } else {
            showError(error: "Documents directory does not exist")
        }
    }
    
    func loadData() -> Data {
        if let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dataFileUrl = documentsDirectoryUrl.appendingPathComponent("data.txt")
            do {
                let contents = try String(contentsOf: dataFileUrl)
                var data: Data = [:]
                var section = ""
                for component in contents.components(separatedBy: .newlines) {
                    if (component.isEmpty) {
                        continue
                    }
                    
                    if (component.hasPrefix("[") && component.hasSuffix("]")) {
                        section = String(component.dropFirst().dropLast())
                        data[section] = data[section] ?? [] // Prevent data loss due to name conflict
                    } else {
                        var array = data[section] ?? []
                        array.append(component)
                        data[section] = array
                    }
                }
                
                return data
            } catch {
                showError(error: "Failed to initialize the data file")
            }
        } else {
            showError(error: "Documents directory does not exist")
        }
        
        return [:]
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
