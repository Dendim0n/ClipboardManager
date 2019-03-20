//
//  Tools.swift
//  Clipboard
//
//  Created by 任岐鸣 on 2019/3/15.
//  Copyright © 2019 Qiming. All rights reserved.
//

import Foundation
import AppKit

typealias keyOperation = () -> Void
typealias keyRemoveOperation = (HistoryContent) -> Void
typealias keyDownOperation = (NSEvent) -> Void
typealias OnNewCopyHook = (Any,NSRunningApplication?) -> Void
typealias OnRemovedCopyHook = () -> Void

struct PopoverSize {
    static let height = 240
    static let width = 360
    static let searchFieldHeight = 48
    static let scrollWidth = 180
}
