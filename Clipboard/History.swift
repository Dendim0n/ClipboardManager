import AppKit

enum HistoryContentType: Int {
    case data = 0
    case string = 1
}


struct HistoryContent:Codable {
    var contentType:Int
    var data:Data?
    var string:String?
    init(contentType: Int, data:Data?, string:String?) {
        self.contentType = contentType
        self.data = data
        self.string = string
    }
}

extension HistoryContent {
    func encode() -> Data {
        let archiver = NSKeyedArchiver.init(requiringSecureCoding: true)
        archiver.encode(self.contentType, forKey: "type")
        if let data = self.data {
            archiver.encode(NSData(data: data), forKey: "data")
        }
        archiver.encode(self.string, forKey: "string")
        archiver.finishEncoding()
        let data = archiver.encodedData
        return data as Data
    }
    
    init?(data: Data) {
        let unarchiver = try? NSKeyedUnarchiver.init(forReadingFrom: data)
        if unarchiver == nil {
            return nil
        }
        defer {
            unarchiver!.finishDecoding()
        }
        
        if let data = unarchiver!.decodeObject(forKey: "data") as? NSData {
            self.data = Data(referencing: data)
        }
        self.string = unarchiver!.decodeObject(forKey: "string") as? String
        self.contentType = Int(unarchiver!.decodeInteger(forKey: "type"))
    }
}

class History {
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
            saveToDisk()
        }
    }
    
    func add(_ content: Any) {
        var item:HistoryContent?
        var old = [HistoryContent]()
        if content is String {
            print("content is String")
            item = HistoryContent(contentType: HistoryContentType.string.rawValue, data: nil, string: content as? String)
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
            item = HistoryContent(contentType: HistoryContentType.data.rawValue, data: content as? Data, string: nil)
            old = contentStorage.filter {
                if let str = $0.data {
                    return str != content as! Data
                } else {
                    return true
                }
            }
        }
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
        self.contentStorage = data.compactMap { return HistoryContent(data: $0) }
    }
    func saveToDisk() {
        let contents = self.contentStorage.map { $0.encode() }
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
