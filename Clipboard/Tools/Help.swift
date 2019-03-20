//
//  File.swift
//  Clipboard
//
//  Created by 任岐鸣 on 2019/3/15.
//  Copyright © 2019 Qiming. All rights reserved.
//
import Cocoa

class Help {
    
    private let iconCreditsText = "使用帮助\n\n"
    private let familyCreditsText = "⇧+⌘+C  =  打开面板\n↑/↓/←/→ = 浏览\nESC  =  退出\n ->|  =  切换大小写\n在列表中+回车 = 复制选择项\n在界面内直接打字即可搜索\n"
    
    @objc
    func openHelp(_ sender: NSMenuItem) {
        NSApp.activate(ignoringOtherApps: true)
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attr = [NSAttributedString.Key.foregroundColor: NSColor.labelColor, NSAttributedString.Key.paragraphStyle:style]
        let iconCredits = NSMutableAttributedString(string: iconCreditsText, attributes: attr)
        
        let credits = NSMutableAttributedString(attributedString: iconCredits)
        credits.append(NSAttributedString(string: familyCreditsText, attributes: attr))
        
        NSApp.orderFrontStandardAboutPanel(options: [NSApplication.AboutPanelOptionKey.credits: credits])
    }
}
