import AppKit

class Clipboard {
    
    static let shared = Clipboard()
    
    private let pasteboard = NSPasteboard.general
    private let timerInterval = 0.5
    
    private var changeCount: Int
    private var onNewCopyHooks: [OnNewCopyHook]
    private var onRemovedCopyHooks: [OnRemovedCopyHook]
    
    init() {
        changeCount = pasteboard.changeCount
        onNewCopyHooks = []
        onRemovedCopyHooks = []
    }
    
    func onNewCopy(_ hook: @escaping OnNewCopyHook) {
        onNewCopyHooks.append(hook)
    }
    
    func onRemovedCopy(_ hook: @escaping OnRemovedCopyHook) {
        onRemovedCopyHooks.append(hook)
    }
    
    func startListening() {
        Timer.scheduledTimer(timeInterval: timerInterval,
                             target: self,
                             selector: #selector(checkForChangesInPasteboard),
                             userInfo: nil,
                             repeats: true)
    }
    
    @objc
    func checkForChangesInPasteboard() {
        guard pasteboard.changeCount != changeCount else {
            return
        }
        let app = NSWorkspace.shared.frontmostApplication
        if let lastItem = pasteboard.string(forType: NSPasteboard.PasteboardType.string) {
            for hook in onNewCopyHooks {
                hook(lastItem, app)
            }
        } else if let lastItem = pasteboard.data(forType: NSPasteboard.PasteboardType.png) {
            for hook in onNewCopyHooks {
                hook(lastItem, app)
            }
        } else {
            for hook in onRemovedCopyHooks {
                hook()
            }
        }
        changeCount = pasteboard.changeCount
    }
}
// MARK: Copy Action
extension Clipboard {
    func copy(_ string: String) {
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(string, forType: NSPasteboard.PasteboardType.string)
    }
    func copy(_ data: Data) {
        pasteboard.declareTypes([NSPasteboard.PasteboardType.png], owner: nil)
        pasteboard.setData(data, forType: NSPasteboard.PasteboardType.png)
    }
    func shouldAccept(item:Any) {
        let type = NSPasteboard.PasteboardType.self
        let typeArr =  [type.string,type.pdf,type.tiff,type.png,type.rtf,type.rtfd,type.html,type.tabularText,type.font,type.ruler,type.color,type.sound,type.multipleTextSelection,
            type.textFinderOptions,type.URL,type.fileURL]
        for type in typeArr {
//            if item == pasteboard.
        }
        
    }
}
