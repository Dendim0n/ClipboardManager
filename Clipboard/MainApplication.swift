import Cocoa

class MainApplication {
    static let shared = MainApplication()
    //    private let popoverStatus:PopOverStatusMenu = {
    //        let pop = PopOverStatusMenu()
    //        return pop
    //    }()
    let popoverClip:PopOverClipboard = {
        let pop = PopOverClipboard()
        return pop
    }()
    var copyMonitor: AnyObject?
    var clipboardPopoverMonitor: AnyObject?
    var window:NSWindow?
    var runningApplication:NSRunningApplication?
    private static let titles = ["=。=","mua!","mua~","嘿嘿嘿",""]
    private let about = About()
    private let help = Help()
    private lazy var statusItem:NSStatusItem = {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        return item
    }()
    //    private let rightMenu = ClipboardMenu(title: titles)
    private lazy var topMenu:NSMenu = {
        let titleStr = MainApplication.titles.randomElement()!
        let m = NSMenu(title: titleStr)
        m.addItem(clearItem)
//        m.addItem(NSMenuItem.separator())
//        m.addItem(switchDictItem)
//        m.addItem(switchSensitiveItem)
        m.addItem(NSMenuItem.separator())
        m.addItem(helpItem)
        m.addItem(aboutItem)
        m.addItem(NSMenuItem(title: "退出", action: #selector(NSApp.stop), keyEquivalent: "q"))
        return m
    }()
    private let showInStatusBar = "showInStatusBar"
    
    
    private var clearItem: NSMenuItem {
        let item = NSMenuItem(title: "清除", action: #selector(clear), keyEquivalent: "")
        item.target = self
        return item
    }
    
//    private var switchDictItem: NSMenuItem {
//        let item = NSMenuItem(title: "tab键切换词典", action: #selector(switchDict), keyEquivalent: "d")
//        item.target = self
//        return item
//    }
//
//    private var switchSensitiveItem: NSMenuItem {
//        let item = NSMenuItem(title: "tab键切换大小写", action: #selector(switchSensitive), keyEquivalent: "s")
//        item.target = self
//        return item
//    }
    
//    @objc private func switchDict() {
//        UserDefaults.standard.set(true, forKey: "dict")
//        UserDefaults.standard.set(false, forKey: "sensitive")
//        switchSensitiveItem.state = NSControl.StateValue(rawValue: 0)
//        switchDictItem.state = NSControl.StateValue(rawValue: 1)
//    }
//    @objc private func switchSensitive() {
//        UserDefaults.standard.set(true, forKey: "sensitive")
//        UserDefaults.standard.set(false, forKey: "dict")
//        switchSensitiveItem.state = NSControl.StateValue(rawValue: 1)
//        switchDictItem.state = NSControl.StateValue(rawValue: 0)
//    }
    
    
    private var aboutItem: NSMenuItem {
        let item = NSMenuItem(title: "关于", action: #selector(about.openAbout), keyEquivalent: "")
        item.target = about
        return item
    }
    
    private var helpItem: NSMenuItem {
        let item = NSMenuItem(title: "帮助", action: #selector(help.openHelp), keyEquivalent: "")
        item.target = help
        return item
    }
    
    init() {
        UserDefaults.standard.register(defaults: [showInStatusBar: true])
    }
    
    func start() {
        if UserDefaults.standard.bool(forKey: showInStatusBar) {
            statusItem.button!.image = NSImage(named: "StatusBarMenuImage")
            //            statusItem.button!.image?.isTemplate = true
            //            statusItem.highlightMode = true
            statusItem.menu = topMenu
        }
        
        refresh()
        History.shared
        HistoryDB.shared.readFromFMDB()
        Clipboard.shared.onNewCopy(History.shared.add)
        Clipboard.shared.onNewCopy({_,_  in self.refresh()})
        Clipboard.shared.onRemovedCopy(History.shared.removeLast)
        Clipboard.shared.onRemovedCopy({ self.refresh() })
        
        Clipboard.shared.startListening()
        copyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (e) in
            
            //            print("copy detected.")
            let cmd = (e.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == NSEvent.ModifierFlags.command.rawValue
            
            if !cmd {
                return
            }
            
            if let key = e.charactersIgnoringModifiers {
                if key.uppercased() == "C" {
                    print("copy detected")
                    //                    Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: "treatCopy", userInfo: nil, repeats: false)
                }
            }
            } as AnyObject
    }
    
    //    func popUpRightMouseMenu() {
    //        rightMenu.headerItemView.title = MainApplication.titles.randomElement()!
    //        refresh()
    //        rightMenu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    //    }
    //
    func popUpVC() {
        
    }
    
    private func refresh() {
        //        let filterItem = rightMenu.item(at: 0)
        //        rightMenu.removeAllItems()
        //        rightMenu.addItem(filterItem!)
        //        populateItems()
        //        populateFooter()
    }
    
    //    private func populateItems() {
    //        for entry in History.shared.contentStorage {
    //            rightMenu.addItem(historyItem(entry))
    //        }
    //    }
    
    //    private func populateFooter() {
    //        rightMenu.addItem(NSMenuItem.separator())
    //        rightMenu.addItem(clearItem)
    //    }
    //
    //    private func addItem(_ content: HistoryContent) {
    //        rightMenu.insertItem(historyItem(content), at: 0)
    //    }
    
    //    private func historyItem(_ content: HistoryContent) -> HistoryMenuItem {
    //        return HistoryMenuItem(content: content)
    //    }
    
    @objc
    func clear(_ sender: NSMenuItem) {
        closeClipPopover()
        History.shared.clear()
    }
}
extension MainApplication { //new popover view controller
    func openClipPopover() {
        
        let pid:pid_t = NSWorkspace.shared.frontmostApplication!.processIdentifier
        runningApplication = NSRunningApplication(processIdentifier: pid)
        let windowRect = NSRect(origin: NSEvent.mouseLocation, size: CGSize(width: 10, height: 10))
        window = NSWindow(contentRect: windowRect, styleMask: .borderless, backing: .buffered, defer: true)
        window!.isOpaque = false
        window!.backgroundColor = NSColor.clear
        window!.level = .statusBar
        window!.setAccessibilityHidden(true)
        window!.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        popoverClip.show(relativeTo: .zero, of: window!.contentView!, preferredEdge: .maxY)
        clipboardPopoverMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { (event) in
            self.closeClipPopover()
            } as AnyObject
    }
    
    func closeClipPopover() {
        (popoverClip.contentViewController as! ClipboardContentViewController).hideAllPreview()
        popoverClip.close()
        window?.orderOut(nil)
        if let monitor : AnyObject = clipboardPopoverMonitor {
            NSEvent.removeMonitor(monitor)
            clipboardPopoverMonitor = nil
        }
        window = nil
        runningApplication?.activate(options: .activateAllWindows)
    }
}
extension MainApplication { //popover in statusbar
    func setStatusItem() {
        if let statusButton = statusItem.button {
            //            statusButton.image = NSImage(named: "Status")
            //            statusButton.alternateImage = NSImage(named: "StatusHighlighted")
            
            //
            // WORKAROUND
            //
            // DummyControl interferes mouseDown events to keep statusButton highlighted while popover is open.
            //
            //            let dummyControl = DummyControl()
            //            dummyControl.frame = statusButton.bounds
            //            statusButton.addSubview(dummyControl)
            //            statusButton.superview!.subviews = [statusButton, dummyControl]
            //            dummyControl.action = #selector(MainApplication.onPress)
            //            dummyControl.target = self
        }
    }
    //    @objc func onPress() {
    //        if popoverStatus.isShown == false {
    //            openMenuPopover()
    //        }
    //        else {
    //            closeMenuPopover()
    //        }
    //    }
    //    func openMenuPopover() {
    //        if let statusButton = statusItem.button {
    //            statusButton.highlight(true)
    //            popoverStatus.show(relativeTo: NSZeroRect, of: statusButton, preferredEdge: NSRectEdge.minY)
    //            statusBarPopoverMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { (event) in
    //                self.closeMenuPopover()
    //                } as AnyObject
    //        }
    //    }
    
    //    func closeMenuPopover() {
    //        popoverStatus.close()
    //        if let statusButton = statusItem.button {
    //            statusButton.highlight(false)
    //        }
    //        if let monitor : AnyObject = statusBarPopoverMonitor {
    //            NSEvent.removeMonitor(monitor)
    //            statusBarPopoverMonitor = nil
    //        }
    //    }
}
