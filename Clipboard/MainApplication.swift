import Cocoa

class MainApplication {
    static let shared = MainApplication()
    private let popoverStatus:PopOverStatusMenu = {
        let pop = PopOverStatusMenu()
        return pop
    }()
    let popoverClip:PopOverClipboard = {
        let pop = PopOverClipboard()
        return pop
    }()
    var statusBarPopoverMonitor: AnyObject?
    var clipboardPopoverMonitor: AnyObject?
    var window:NSWindow?
    private static let titles = ["=。=","mua!","mua~","嘿嘿嘿",""]
    private let about = About()
    private lazy var statusItem:NSStatusItem = {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        return item
    }()
    private let rightMenu = ClipboardMenu(title: titles)
    private lazy var topMenu:NSMenu = {
        let titleStr = MainApplication.titles.randomElement()!
        let m = NSMenu(title: titleStr)
        m.addItem(clearItem)
        m.addItem(NSMenuItem.separator())
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
    
    private var aboutItem: NSMenuItem {
        let item = NSMenuItem(title: "关于", action: #selector(about.openAbout), keyEquivalent: "")
        item.target = about
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
        
        Clipboard.shared.onNewCopy(History.shared.add)
        Clipboard.shared.onNewCopy({_ in self.refresh()})
        Clipboard.shared.onRemovedCopy(History.shared.removeLast)
        Clipboard.shared.onRemovedCopy({ self.refresh() })
        
        Clipboard.shared.startListening()
    }
    
    func popUpRightMouseMenu() {
        rightMenu.headerItemView.title = MainApplication.titles.randomElement()!
        refresh()
        rightMenu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }
    
    func popUpVC() {
        
    }
    
    private func refresh() {
        let filterItem = rightMenu.item(at: 0)
        rightMenu.removeAllItems()
        rightMenu.addItem(filterItem!)
        populateItems()
        populateFooter()
    }
    
    private func populateItems() {
        for entry in History.shared.contentStorage {
            rightMenu.addItem(historyItem(entry))
        }
    }
    
    private func populateFooter() {
        rightMenu.addItem(NSMenuItem.separator())
        rightMenu.addItem(clearItem)
    }
    
    private func addItem(_ content: HistoryContent) {
        rightMenu.insertItem(historyItem(content), at: 0)
    }
    
    private func historyItem(_ content: HistoryContent) -> HistoryMenuItem {
        return HistoryMenuItem(content: content)
    }
    
    @objc
    func clear(_ sender: NSMenuItem) {
        History.shared.clear()
        rightMenu.removeAllItems()
        populateFooter()
    }
}
extension MainApplication { //new popover view controller
    func openClipPopover() {
        let windowRect = NSRect(origin: NSEvent.mouseLocation, size: CGSize(width: 10, height: 10))
        window = NSWindow(contentRect: windowRect, styleMask: .borderless, backing: .buffered, defer: true)
        window!.isOpaque = false
        window!.backgroundColor = NSColor.clear
        window!.level = .statusBar
//        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.StatusWindowLevelKey)))
        window!.setAccessibilityHidden(true)
        window!.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        popoverClip.show(relativeTo: .zero, of: window!.contentView!, preferredEdge: .maxY)
        clipboardPopoverMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { (event) in
            self.closeClipPopover()
            } as AnyObject
    }
    
    func closeClipPopover() {
        popoverClip.close()
        if let monitor : AnyObject = clipboardPopoverMonitor {
            NSEvent.removeMonitor(monitor)
            statusBarPopoverMonitor = nil
        }
        window = nil
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
            let dummyControl = DummyControl()
            dummyControl.frame = statusButton.bounds
            statusButton.addSubview(dummyControl)
            statusButton.superview!.subviews = [statusButton, dummyControl]
            dummyControl.action = #selector(MainApplication.onPress)
            dummyControl.target = self
        }
    }
    @objc func onPress() {
        if popoverStatus.isShown == false {
            openMenuPopover()
        }
        else {
            closeMenuPopover()
        }
    }
    func openMenuPopover() {
        if let statusButton = statusItem.button {
            statusButton.highlight(true)
            popoverStatus.show(relativeTo: NSZeroRect, of: statusButton, preferredEdge: NSRectEdge.minY)
            statusBarPopoverMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { (event) in
                self.closeMenuPopover()
                } as AnyObject
        }
    }
    
    func closeMenuPopover() {
        popoverStatus.close()
        if let statusButton = statusItem.button {
            statusButton.highlight(false)
        }
        if let monitor : AnyObject = statusBarPopoverMonitor {
            NSEvent.removeMonitor(monitor)
            statusBarPopoverMonitor = nil
        }
    }
}
