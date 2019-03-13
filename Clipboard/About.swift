import Cocoa

class About {
    private let defaultCreditsAttributes = [NSAttributedString.Key.foregroundColor: NSColor.labelColor]
    private let iconCreditsText = "This Clipboard manager only for you~\n"
    private let familyCreditsText = "❤️"
    
    @objc
    func openAbout(_ sender: NSMenuItem) {
        NSApp.activate(ignoringOtherApps: true)
        
        let iconCredits = NSMutableAttributedString(string: iconCreditsText, attributes: defaultCreditsAttributes)
        
        let credits = NSMutableAttributedString(attributedString: iconCredits)
        credits.append(NSAttributedString(string: familyCreditsText, attributes: defaultCreditsAttributes))
        
        NSApp.orderFrontStandardAboutPanel(options: [NSApplication.AboutPanelOptionKey.credits: credits])
    }
}
