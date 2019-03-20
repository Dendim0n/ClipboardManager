//
//  HistoryTools.swift
//  Clipboard
//
//  Created by 任岐鸣 on 2019/3/18.
//  Copyright © 2019 Qiming. All rights reserved.
//

import Cocoa
import FMDB

class HistoryDB {
    static let shared = HistoryDB()
    private var dataPath:URL {
        get {
            var url = FileManager.default.homeDirectoryForCurrentUser
            url.appendPathComponent("clipBoard.sqlite")
            return url
        }
    }
    init() {
        threadSafeDB { (db) in
            try? db.executeUpdate("CREATE TABLE IF NOT EXISTS `History` (`type` INTEGER,`data`    BLOB,`string` TEXT,`source` TEXT,`icon` BLOB);", values: nil)
        }
    }
    func threadSafeDB(block:(FMDatabase) -> Void) {
        let queue = FMDatabaseQueue(url: self.dataPath)
        queue?.inDatabase(block)
    }
    func addToDB(content:HistoryContent) {
        delIfExists(content: content)
            threadSafeDB { (db) in
                try? db.executeUpdate("insert into `History`(`type`,`data`,`string`,`source`,`icon`) values(?, ?, ?, ?, ?);", values: [content.contentType, content.data, content.string, content.sourceApp, content.iconData()])
            }
    }
    func removeFirst() {
        threadSafeDB { (db) in
            if let result = try? db.executeQuery("SELECT * FROM History", values: nil) {
                result.next()
                let content = HistoryContent(contentType: Int(result.int(forColumn: "type")),
                                             data: result.data(forColumn: "data"),
                                             string: result.string(forColumn: "string"),
                                             iconData: result.data(forColumn: "icon"),
                                             sourceApp: result.string(forColumn: "source"))
                try? db.executeUpdate("delete FROM History where data=? and string=?", values: [content.data, content.string])
            }
        }
    }
    func delIfExists(content:HistoryContent) {
        threadSafeDB { (db) in
            if let data = content.data {
                try? db.executeUpdate("delete FROM History where data=?", values: [data])
            } else if let str = content.string {
                try? db.executeUpdate("delete FROM History where string=?", values: [str])
            }
        }
    }
    func readFromFMDB() {
        DispatchQueue.global().async {
            self.threadSafeDB { (db) in
                if let result = try? db.executeQuery("SELECT * FROM History", values: nil) {
                    var res = [HistoryContent]()
                    while(result.next()) {
                        let content = HistoryContent(contentType: Int(result.int(forColumn: "type")),
                                                     data: result.data(forColumn: "data"),
                                                     string: result.string(forColumn: "string"),
                                                     iconData: result.data(forColumn: "icon"),
                                                     sourceApp: result.string(forColumn: "source"))
                        res.append(content)
                    }
                    History.shared.contentStorage = res.reversed()
                    print("db loaded.")
                    if let vc = MainApplication.shared.popoverClip.contentViewController as? ClipboardContentViewController {
                        DispatchQueue.main.async {
                            vc.loading = false
                            vc.emptyPrompt.stringValue = "无历史记录"
                            vc.emptyPrompt.alphaValue = 0.5
                            vc.refresh()
                        }
                    }
                    DispatchQueue.global().async {
                        if let vc = MainApplication.shared.popoverClip.contentViewController as? ClipboardContentViewController {
                            DispatchQueue.main.async {
                                vc.loading = false
                                if History.shared.contentStorage.count == 0 {
                                    vc.emptyPrompt.stringValue = "无历史记录"
                                    vc.emptyPrompt.alphaValue = 0.5
                                }
                                vc.refresh()
                            }
                        }
                    }
                }
            }
        }
    }
    func removeAll() {
        threadSafeDB { (db) in
            try? db.executeUpdate("DROP TABLE `History`", values: nil)
            try? db.executeUpdate("CREATE TABLE IF NOT EXISTS `History` (`type` INTEGER,`data`    BLOB,`string` TEXT,`source` TEXT,`icon` BLOB);", values: nil)
            try? db.executeUpdate("VACUUM;", values: nil)
        }
    }
}
