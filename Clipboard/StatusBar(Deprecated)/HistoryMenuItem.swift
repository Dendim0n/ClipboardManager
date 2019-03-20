//import Cocoa
//
//class HistoryMenuItem: NSMenuItem {
//    private let showMaxLength = 50
//    
//    private var fullTitle: String {
//        get {
//            if content!.contentType == HistoryContentType.string.rawValue {
//                return content!.string!
//            } else {
//                return "[image]"
//            }
//        }
//    }
//    private var clipboard: Clipboard?
//    
//    var content:HistoryContent?
//    
//    required init(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//    
//    init(content: HistoryContent) {
//        var title = "[image]"
//        if content.contentType == HistoryContentType.string.rawValue {
//            title = content.string!
//        }
//        super.init(title: title, action: #selector(copy(_:)), keyEquivalent: "")
//        self.target = self
//        self.content = content
////        self.clipboard = clipboard
//        self.title = humanizedTitle(title)
//    }
//    
//    private func humanizedTitle(_ title: String) -> String {
//        let trimmedTitle = title.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//        if trimmedTitle.count > showMaxLength {
//            let index = trimmedTitle.index(trimmedTitle.startIndex, offsetBy: showMaxLength)
//            return "\(trimmedTitle[...index])..."
//        } else {
//            return trimmedTitle
//        }
//    }
//    
//    @objc
//    func copy(_ sender: NSMenuItem) {
//        if content!.contentType == HistoryContentType.string.rawValue {
//            Clipboard.shared.copy(content!.string!)
//        } else {
//            Clipboard.shared.copy(content!.data!)
//        }
//    }
//}
