import UIKit

enum ItemsError: Error {
    case documentsDirectoryDoesNotExist
    case failedToRead
    case noSectionWithIndex(index: Int, count: Int)
    case failedToWrite
}

// TODO: Remove ! in favor of throwing errors
class Items {
    var items: [String: [String]] = [:]

    init() throws {
        if let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let itemsFileUrl = documentsDirectoryUrl.appendingPathComponent("data.txt")
            if let contents = try? String(contentsOf: itemsFileUrl) {
                var section = ""
                for component in contents.components(separatedBy: .newlines) {
                    // Ignore empty lines
                    if (component.isEmpty) {
                        continue
                    }
                    
                    if (component.hasPrefix("[") && component.hasSuffix("]")) {
                        section = String(component.dropFirst().dropLast())
                        // Prevent resetting a section if it appears multiple times
                        if !items.keys.contains(section) {
                            items[section] = []
                        }
                    } else {
                        if var array = items[section] {
                            array.append(component)
                            items[section] = array
                        } else {
                            items[section] = [component]
                        }
                    }
                }
            } else {
                throw ItemsError.failedToRead
            }
        } else {
            throw ItemsError.documentsDirectoryDoesNotExist
        }
    }
    
    // TODO: Error handling
    @inline(__always) func add(section: String, item: String) throws -> (Int, Int) {
        if var array = items[section] {
            array.append(item)
            items[section] = array
        } else {
            items[section] = [item]
        }
        
        let sectionIndex = Array(items.keys).index(of: section)! // TODO: Fix the error without Array()
        let itemIndex = items[section]!.index(of: item)!
        try save()
        return (itemIndex, sectionIndex)
    }
    
    @inline(__always) func getSectionCount() -> Int {
        return items.keys.count
    }
    
    @inline(__always) func getSectionName(index: Int) -> String {
        return Array(items.keys)[index]
    }
    
    @inline(__always) func getSectionItems(index: Int) -> [String]? {
        return items[Array(items.keys)[index]]
    }

    @inline(__always) func getSectionItemsCount(sectionIndex: Int) throws -> Int {
        if let array = getSectionItems(index: sectionIndex) {
            return array.count
        } else {
            throw ItemsError.noSectionWithIndex(index: sectionIndex, count: getSectionCount())
        }
    }
    
    @inline(__always) func getItem(sectionIndex: Int, index: Int) throws -> String? {
        if let array = getSectionItems(index: sectionIndex) {
            return array[index]
        } else {
            throw ItemsError.noSectionWithIndex(index: sectionIndex, count: getSectionCount())
        }
    }
    
    @inline(__always) func removeItem(sectionIndex: Int, index: Int) throws -> String {
        if var array = getSectionItems(index: sectionIndex) {
            let item = array[index]
            array.remove(at: index)
            return item
        } else {
            throw ItemsError.noSectionWithIndex(index: sectionIndex, count: getSectionCount())
        }
    }
    
    @inline(__always) func insertItem(sectionIndex: Int, index: Int, item: String) throws {
        if var array = getSectionItems(index: sectionIndex) {
            let item = array[index]
            array.insert(item, at: index)
        } else {
            throw ItemsError.noSectionWithIndex(index: sectionIndex, count: getSectionCount())
        }
    }

    private func save() throws {
        if let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dataFileUrl = documentsDirectoryUrl.appendingPathComponent("data.txt")
            do {
                var contents = ""
                for (section, items) in items {
                    contents.append("[" + section + "]\n")
                    for item in items {
                        contents.append(item + "\n")
                    }
                }
                
                try contents.write(to: dataFileUrl, atomically: false, encoding: .utf8)
            } catch {
                throw ItemsError.failedToWrite
            }
        } else {
            throw ItemsError.documentsDirectoryDoesNotExist
        }
    }
}
