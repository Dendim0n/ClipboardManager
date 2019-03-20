//
//  PopoverSearchField.swift
//  Clipboard
//
//  Created by 任岐鸣 on 2019/3/14.
//  Copyright © 2019 Qiming. All rights reserved.
//

import Cocoa
import Carbon
import HotKey
//TODO: 上下键绑定。
class PopoverSearchField: NSSearchField,NSSearchFieldDelegate {
    var copyAction:keyOperation?
    var cancelAction:keyOperation?
    var browseAction:keyOperation?
    var sensitiveAction:keyOperation?
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.focusRingType = .none
        self.delegate = self
        self.font = NSFont.systemFont(ofSize: 16)
//        self.isBordered = false
//        self.alignment = .center
//        self.action = #selector(customAction)
    }
    required init?(coder: NSCoder) {
        return nil
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(insertNewline(_:)) {
            if self.copyAction != nil {
                self.copyAction!()
            }
        }
        if commandSelector == #selector(moveDown(_:)) {
            if self.browseAction != nil {
                self.browseAction!()
            }
        }
        if commandSelector == #selector(insertTab(_:)) {
            switchSensitive()
        }
        return false
    }
//    override func insertTab(_ sender: Any?) {
//    }
    func switchSensitive() {
        if let action = self.sensitiveAction {
            action()
        }
    }
    override func cancelOperation(_ sender: Any?) {
        guard self.stringValue.count == 0 else {
            super.cancelOperation(sender)
            return
        }
        if cancelAction != nil {
            cancelAction!()
        }
    }
//    override func keyDown(with event: NSEvent) { //useless!
//        super.keyDown(with: event)
//    }
    override func keyUp(with event: NSEvent) { //use this to handle becomeFirstResponder's first character
        if let currentRange = self.currentEditor()?.selectedRange {
            if currentRange.location > 10000 || currentRange.length > 10000 || (currentRange.location == 0 && currentRange.length == 1) {
                self.currentEditor()?.selectedRange = NSMakeRange(1, 0)
            }
        }
        super.keyUp(with: event)
    }
}
