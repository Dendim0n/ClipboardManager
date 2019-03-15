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
    var img = NSImageView()
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(txt)
        addSubview(img)
        txt.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(img.snp.right).offset(2)
            make.right.equalToSuperview().offset(-2)
        }
        img.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(2)
            make.width.height.equalTo(12)
        }
        txt.isBezeled = false
        txt.usesSingleLineMode = true
        txt.textColor = .white
        txt.isEditable = false
        txt.drawsBackground = true
        txt.backgroundColor = .clear
        txt.font = NSFont.systemFont(ofSize: 12)
        self.textField = txt
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
