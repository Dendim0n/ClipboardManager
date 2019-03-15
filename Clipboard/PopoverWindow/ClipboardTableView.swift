//
//  ClipboardTableview.swift
//  Clipboard
//
//  Created by 任岐鸣 on 2019/3/15.
//  Copyright © 2019 Qiming. All rights reserved.
//

import Foundation
import AppKit
import Carbon

class ClipBoardTableView: NSTableView {
    var upArrowAction: keyOperation?
    var resignAction: keyDownOperation?
    var sensitiveAction: keyOperation?
    override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case Int(kVK_ANSI_A): fallthrough
        case Int(kVK_ANSI_S): fallthrough
        case Int(kVK_ANSI_D): fallthrough
        case Int(kVK_ANSI_F): fallthrough
        case Int(kVK_ANSI_H): fallthrough
        case Int(kVK_ANSI_G): fallthrough
        case Int(kVK_ANSI_Z): fallthrough
        case Int(kVK_ANSI_X): fallthrough
        case Int(kVK_ANSI_C): fallthrough
        case Int(kVK_ANSI_V): fallthrough
        case Int(kVK_ANSI_B): fallthrough
        case Int(kVK_ANSI_Q): fallthrough
        case Int(kVK_ANSI_W): fallthrough
        case Int(kVK_ANSI_E): fallthrough
        case Int(kVK_ANSI_R): fallthrough
        case Int(kVK_ANSI_Y): fallthrough
        case Int(kVK_ANSI_T): fallthrough
        case Int(kVK_ANSI_1): fallthrough
        case Int(kVK_ANSI_2): fallthrough
        case Int(kVK_ANSI_3): fallthrough
        case Int(kVK_ANSI_4): fallthrough
        case Int(kVK_ANSI_6): fallthrough
        case Int(kVK_ANSI_5): fallthrough
        case Int(kVK_ANSI_Equal): fallthrough
        case Int(kVK_ANSI_9): fallthrough
        case Int(kVK_ANSI_7): fallthrough
        case Int(kVK_ANSI_Minus): fallthrough
        case Int(kVK_ANSI_8): fallthrough
        case Int(kVK_ANSI_0): fallthrough
        case Int(kVK_ANSI_RightBracket): fallthrough
        case Int(kVK_ANSI_O): fallthrough
        case Int(kVK_ANSI_U): fallthrough
        case Int(kVK_ANSI_LeftBracket): fallthrough
        case Int(kVK_ANSI_I): fallthrough
        case Int(kVK_ANSI_P): fallthrough
        case Int(kVK_ANSI_L): fallthrough
        case Int(kVK_ANSI_J): fallthrough
        case Int(kVK_ANSI_Quote): fallthrough
        case Int(kVK_ANSI_K): fallthrough
        case Int(kVK_ANSI_Semicolon): fallthrough
        case Int(kVK_ANSI_Backslash): fallthrough
        case Int(kVK_ANSI_Comma): fallthrough
        case Int(kVK_ANSI_Slash): fallthrough
        case Int(kVK_ANSI_N): fallthrough
        case Int(kVK_ANSI_M): fallthrough
        case Int(kVK_ANSI_Period): fallthrough
        case Int(kVK_ANSI_Grave): fallthrough
        case Int(kVK_ANSI_KeypadDecimal): fallthrough
        case Int(kVK_ANSI_KeypadMultiply): fallthrough
        case Int(kVK_ANSI_KeypadPlus): fallthrough
        case Int(kVK_ANSI_KeypadClear): fallthrough
        case Int(kVK_ANSI_KeypadDivide): fallthrough
        case Int(kVK_ANSI_KeypadEnter): fallthrough
        case Int(kVK_ANSI_KeypadMinus): fallthrough
        case Int(kVK_ANSI_KeypadEquals): fallthrough
        case Int(kVK_ANSI_Keypad0): fallthrough
        case Int(kVK_ANSI_Keypad1): fallthrough
        case Int(kVK_ANSI_Keypad2): fallthrough
        case Int(kVK_ANSI_Keypad3): fallthrough
        case Int(kVK_ANSI_Keypad4): fallthrough
        case Int(kVK_ANSI_Keypad5): fallthrough
        case Int(kVK_ANSI_Keypad6): fallthrough
        case Int(kVK_ANSI_Keypad7): fallthrough
        case Int(kVK_ANSI_Keypad8): fallthrough
        case Int(kVK_ANSI_Keypad9):
            if resignAction != nil {
                resignAction!(event)
            }
            break
        case Int(kVK_UpArrow):
            if self.selectedRow == 0 && upArrowAction != nil {
                upArrowAction!()
            } else {
                super.keyDown(with: event)
            }
            break
        case Int(kVK_Tab):
            if sensitiveAction != nil {
                sensitiveAction!()
            }
            break
        default:
            super.keyDown(with: event)
        }
    }
}
class HistoryTableRowView: NSTableRowView {
    
    override func drawSelection(in dirtyRect: NSRect) {
        if self.selectionHighlightStyle != .none {
            let selectionRect = NSInsetRect(self.bounds, 2.5, 2.5)
            NSColor(calibratedWhite: 0.65, alpha: 1).setStroke()
//            NSColor(calibratedWhite: 0.82, alpha: 1).setFill()
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
            selectionPath.fill()
            selectionPath.stroke()
        }
    }
}
