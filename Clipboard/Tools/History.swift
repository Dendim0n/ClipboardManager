import AppKit

class History {
    static let shared = History()
    private var dataPath:URL {
        get {
            var url = FileManager.default.homeDirectoryForCurrentUser
            url.appendPathComponent("clipBoard.history")
            return url
        }
    }
    private let contentKey = "historyContent"
    private let maxSize = 999
    
    private let defaults = UserDefaults.standard
    
    var contentStorage = [HistoryContent]() {
        didSet {
            if oldValue.count != 0 || contentStorage.count == 1{
                saveToDisk()
            }
        }
    }
    
    func add(content: Any, sourceApp:NSRunningApplication?) {
        var item:HistoryContent?
        var contentType = HistoryContentType.string.rawValue
        var old = [HistoryContent]()
        if content is String {
            print("content is String")
            old = contentStorage.filter {
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
            old = contentStorage.filter {
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
        contentStorage = [item!] + old
    }
    init() {
        readFromDisk()
    }
    deinit {
        saveToDisk()
    }
    func readFromDisk() {
        guard let data = UserDefaults.standard.object(forKey: "history") as? [Data] else {
            self.contentStorage = [HistoryContent]()
            return
        }
        DispatchQueue.global().async {
            
            self.contentStorage = data.parallel.compactMap{ return HistoryContent(data: $0)}
            if let vc = MainApplication.shared.popoverClip.contentViewController as? ClipboardContentViewController {
                DispatchQueue.main.async {
                    vc.loading = false
                    vc.refresh()
                }
            }
        }
    }
    func saveToDisk() {
        let contents = self.contentStorage.parallel.map { $0.encode() }
        UserDefaults.standard.set(contents, forKey: "history")
    }
    
    func removeLast() {
        var history = contentStorage
        if !history.isEmpty {
            history.removeLast()
            contentStorage = history
        }
    }
    
    func clear() {
        UserDefaults.standard.set([], forKey: "history")
        readFromDisk()
    }
}
