import UIKit

class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidAppear(_ animated: Bool) {
        // Create empty data file to be able to tell the application successfully writes to the Files app
        if let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dataFileUrl = documentsDirectoryUrl.appendingPathComponent("data.txt")
            if !FileManager.default.fileExists(atPath: dataFileUrl.path) {
                saveData(data: "")
            }
        } else {
            showError(error: "Documents directory does not exist")
        }

        contentTextView.delegate = self
        contentTextView.text = loadData()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        saveData(data: textView.text)
    }
    
    func showError(error: String) {
        let alert = UIAlertController(title: "Day", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveData(data: String) {
        if let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dataFileUrl = documentsDirectoryUrl.appendingPathComponent("data.txt")
            do {
                try data.write(to: dataFileUrl, atomically: false, encoding: .utf8)
            } catch {
                showError(error: "Failed to initialize the data file")
            }
        } else {
            showError(error: "Documents directory does not exist")
        }
    }
    
    func loadData() -> String {
        if let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dataFileUrl = documentsDirectoryUrl.appendingPathComponent("data.txt")
            do {
                return try String(contentsOf: dataFileUrl)
            } catch {
                showError(error: "Failed to initialize the data file")
            }
        } else {
            showError(error: "Documents directory does not exist")
        }
        
        return ""
    }
}
