//
//  PopOverCell.swift
//  Clipboard
//
//  Created by 任岐鸣 on 2019/3/14.
//  Copyright © 2019 Qiming. All rights reserved.
//

import Cocoa

class PopOverCell: NSTableCellView {
    static var lineColor = NSColor.clear
    static var bgColor = NSColor.clear
    static var textColor = NSColor.darkGray
    var txt = NSTextField()
    var img = NSImageView()
    var colorView = NSView()
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(txt)
        addSubview(img)
        addSubview(colorView)
        colorView.wantsLayer = true
//        colorView.layer?.backgroundColor =
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
        colorView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(12)
        }
        colorView.layer?.cornerRadius = 6
        colorView.layer?.backgroundColor = NSColor.clear.cgColor
        txt.isBezeled = false
        txt.usesSingleLineMode = true
        txt.textColor = PopOverCell.textColor
        txt.isEditable = false
        txt.drawsBackground = true
        txt.backgroundColor = PopOverCell.bgColor
        txt.font = NSFont.systemFont(ofSize: 12)
        self.textField = txt
    }
    
    required init?(coder decoder: NSCoder) {
        return nil
    }
    
}
