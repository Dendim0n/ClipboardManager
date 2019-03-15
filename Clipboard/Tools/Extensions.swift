//
//  Extensions.swift
//  Clipboard
//
//  Created by 任岐鸣 on 2019/3/15.
//  Copyright © 2019 Qiming. All rights reserved.
//

import Foundation

extension String {
    func humanizedTitle() -> String {
        let maxLength = 25
        let trimmedTitle = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedTitle.count > maxLength {
            let index = trimmedTitle.index(trimmedTitle.startIndex, offsetBy: maxLength)
            return "\(trimmedTitle[...index])..."
        } else {
            return trimmedTitle
        }
    }
}
