//
//  PopOverCell.swift
//  Clipboard
//
//  Created by 任岐鸣 on 2019/3/14.
//  Copyright © 2019 Qiming. All rights reserved.
//

import Cocoa

class PopOverCell: NSTableCellView {
    var txt = NSTextField()
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(txt)
        txt.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
//        txt.isBezeled = false
        txt.textColor = .white
        txt.isEditable = false
        txt.drawsBackground = false
        self.textField = txt
//        txt.stringValue = "abcde"
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//
//        // Drawing code here.
//    }
    
}
