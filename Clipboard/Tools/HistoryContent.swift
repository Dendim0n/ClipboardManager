//
//  HistoryContent.swift
//  Clipboard
//
//  Created by 任岐鸣 on 2019/3/15.
//  Copyright © 2019 Qiming. All rights reserved.
//

import Cocoa

enum HistoryContentType: Int {
    case data = 0
    case string = 1
}
class Qunarchiver:NSKeyedUnarchiver {
    deinit {
        print("unarchiver deinit")
    }
}
class Qarchiver:NSKeyedArchiver {
    deinit {
        print("archiver deinit")
    }
}
class HistoryContent {
    var contentType:Int
    var data:Data?
    var string:String?
    var icon:NSImage?
    var sourceApp:String?
    func iconData() -> Data? {
        if self.icon != nil {
            return Data(referencing: NSData(data: icon!.tiffRepresentation!))
        } else {
            return nil
        }
    }
    func styleColor() -> CGColor {
        guard data != nil else {
            return NSColor.clear.cgColor
        }
        return NSImage.init(data: self.data!)!.averageColor!
    }
    init(contentType: Int, data:Data?, string:String?, icon:NSImage?, sourceApp:String?) {
        self.contentType = contentType
        self.data = data
        self.string = string
        self.icon = icon
        self.sourceApp = sourceApp
    }
    init(contentType: Int, data:Data?, string:String?, iconData:Data?, sourceApp:String?) {
        self.contentType = contentType
        self.data = data
        self.string = string
        if iconData != nil {
            self.icon = NSImage.init(data: iconData!)
        }
        self.sourceApp = sourceApp
    }
    func previewStr() -> String {
        if self.contentType == 1 {
            if let str = self.string {
                var trimmedString = str.replacingOccurrences(of: "\n", with: "").trimmingCharacters(in: .whitespaces)
                return trimmedString
            }
            return "NONE"
        } else {
            return "[image]"
        }
    }
    deinit {
        print("History Deinit");
    }
}
extension HistoryContent:Equatable {
    public static func == (lhs: HistoryContent, rhs: HistoryContent) -> Bool {
        return lhs.data == rhs.data && lhs.string == rhs.string
    }
}
