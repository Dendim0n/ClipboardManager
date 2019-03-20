import AppKit
import FMDB

class History {
    static let shared = History()
    private let maxSize = 500
    
    var contentStorage = [HistoryContent]() {
        didSet {
            if let vc = MainApplication.shared.popoverClip.contentViewController as? ClipboardContentViewController {
                DispatchQueue.main.async {
                    vc.refresh()
                }
            }
        }
    }
    
    func add(content: Any, sourceApp:NSRunningApplication?) {
        var item:HistoryContent?
        var contentType = HistoryContentType.string.rawValue
        var new = [HistoryContent]()
        if content is String {
            print("content is String")
            new = contentStorage.filter {
                if let str = $0.string {
                    return str != content as! String
                } else {
                    return true
                }
            }
        }
        if content is Data {
            print("content is Data")
            contentType = HistoryContentType.data.rawValue
            new = contentStorage.filter {
                if let str = $0.data {
                    return str != content as! Data
                } else {
                    return true
                }
            }
        }
        let icon = sourceApp?.icon
        let source = sourceApp?.localizedName
        item = HistoryContent(contentType: contentType, data: content as? Data, string: content as? String, icon: icon, sourceApp: source)
//        for i in 0..<300 {
//            print("test iteration:\(i)")
            new.insert(item!, at: 0)
            HistoryDB.shared.addToDB(content: item!)
//        }
        contentStorage = new
    }
    func remove(content:HistoryContent) {
        contentStorage = contentStorage.filter {
            return content != $0
        }
        HistoryDB.shared.delIfExists(content: content)
    }
    
    func removeLast() {
        var history = contentStorage
        if !history.isEmpty {
            history.removeLast()
            contentStorage = history
        }
        HistoryDB.shared.removeFirst()
    }
    
    func clear() {
        self.contentStorage = [HistoryContent]()
        HistoryDB.shared.removeAll()
    }
}
