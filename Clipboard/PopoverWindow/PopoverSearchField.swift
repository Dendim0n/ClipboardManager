//
//  PopoverSearchField.swift
//  Clipboard
//
//  Created by 任岐鸣 on 2019/3/14.
//  Copyright © 2019 Qiming. All rights reserved.
//

import Cocoa
import Carbon
//TODO: 上下键绑定。
typealias keyOperation = () -> Void
class PopoverSearchField: NSSearchField,NSSearchFieldDelegate {
    var copyAction:keyOperation?
    var cancelAction:keyOperation?
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.focusRingType = .none
        self.delegate = self
//        self.action = #selector(customAction)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    override func keyDown(with event: NSEvent) {
//        super.keyDown(with: event)
//    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(insertNewline(_:)) {
//            textView.insertNewlineIgnoringFieldEditor(self)
            if self.copyAction != nil {
                self.copyAction!()
            }
            return false
        }
        return false
    }
//    @objc func customAction() {
//        print(self.stringValue)
//    }
    override func cancelOperation(_ sender: Any?) {
        guard self.stringValue.count == 0 else {
            super.cancelOperation(sender)
            return
        }
        if cancelAction != nil {
            cancelAction!()
        }
    }
    override func keyDown(with event: NSEvent) {
//        if Int(event.keyCode) == Int(kVK_Return) {
//            if self.copyAction != nil {
//                self.copyAction!()
//            }
//            return
//        }
        super.keyDown(with: event)
    }
}
