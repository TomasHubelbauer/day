import UIKit

enum ItemsError: Error {
    case failedToLocate
    case failedToRead
    case noSectionWithIndex(index: Int, count: Int)
    case failedToWrite
}

class Items {
    var sections: [String] = []
    var items: [[String]] = []

    init() throws {
        if let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let itemsFileUrl = documentsDirectoryUrl.appendingPathComponent("data.txt")
            if let contents = try? String(contentsOf: itemsFileUrl) {
                var section = ""
                var hasSection = false
                for component in contents.components(separatedBy: .newlines) {
                    // Ignore empty lines
                    if (component.isEmpty) {
                        continue
                    }
                    
                    if (component.hasPrefix("[") && component.hasSuffix("]")) {
                        section = String(component.dropFirst().dropLast())
                        sections.append(section)
                        hasSection = true
                        items.append([])
                    } else {
                        // Create default section if we have item before section
                        if !hasSection {
                            sections.append(section)
                            items.append([])
                        }
                        
                        items[sections.count - 1].append(component)
                    }
                }
            } else {
                throw ItemsError.failedToRead
            }
        } else {
            throw ItemsError.failedToLocate
        }
    }

    @inline(__always) func queueItem(section: String, _ item: String) throws -> Int {
        let sectionIndex = sections.index(of: section) ?? {
            sections.append(section)
            items.append([])
            return sections.endIndex
        }()
        
        items[sectionIndex].insert(item, at: 0)
        try save()
        return sectionIndex
    }
    
    @inline(__always) func getCount() -> Int {
        return sections.count
    }
    
    @inline(__always) func getCount(sectionIndex: Int) -> Int {
        return items[sectionIndex].count
    }
    
    @inline(__always) func getName(sectionIndex: Int) -> String {
        return sections[sectionIndex]
    }
    
    @inline(__always) func getItem(sectionIndex: Int, itemIndex: Int) -> String {
        return items[sectionIndex][itemIndex]
    }
    
    @inline(__always) func removeItem(sectionIndex: Int, itemIndex: Int) throws -> String {
        let item = items[sectionIndex].remove(at: itemIndex)
        try save()
        return item
    }
    
    @inline(__always) func insertItem(sectionIndex: Int, itemIndex: Int, _ item: String) throws {
        items[sectionIndex].insert(item, at: itemIndex)
        try save()
    }

    private func save() throws {
        if let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let itemsFileUrl = documentsDirectoryUrl.appendingPathComponent("data.txt")
            do {
                var contents = ""
                for (index, items) in items.enumerated() {
                    contents.append("[" + sections[index] + "]\n")
                    for item in items {
                        contents.append(item + "\n")
                    }
                }
                
                try contents.write(to: itemsFileUrl, atomically: true, encoding: .utf8)
            } catch {
                throw ItemsError.failedToWrite
            }
        } else {
            throw ItemsError.failedToLocate
        }
    }
}
