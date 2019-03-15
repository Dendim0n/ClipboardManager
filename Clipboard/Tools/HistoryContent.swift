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

struct HistoryContent {
    var contentType:Int
    var data:Data?
    var string:String?
    var icon:NSImage?
    var sourceApp:String?
    init(contentType: Int, data:Data?, string:String?, icon:NSImage?, sourceApp:String?) {
        self.contentType = contentType
        self.data = data
        self.string = string
        self.icon = icon
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
}

extension HistoryContent {
    func encode() -> Data {
        return autoreleasepool { () -> Data in
            let archiver = NSKeyedArchiver.init(requiringSecureCoding: true)
            archiver.encode(self.contentType, forKey: "type")
            if let data = self.data {
                archiver.encode(NSData(data: data), forKey: "data")
            }
            if let icon = self.icon {
                archiver.encode(NSData(data: icon.tiffRepresentation!), forKey: "icon")
            }
            archiver.encode(self.string, forKey: "string")
            archiver.encode(self.sourceApp, forKey: "sourceApp")
            archiver.finishEncoding()
            let data = archiver.encodedData
            return data
        }
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
        if let data = unarchiver!.decodeObject(forKey: "icon") as? NSData {
            self.icon = NSImage(data: Data(referencing: data))
        }
        self.string = unarchiver!.decodeObject(forKey: "string") as? String
        self.sourceApp = unarchiver!.decodeObject(forKey: "sourceApp") as? String
        self.contentType = Int(unarchiver!.decodeInteger(forKey: "type"))
    }
}
