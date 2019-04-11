//
//  PopOverClipboard.swift
//  Clipboard
//
//  Created by 任岐鸣 on 2019/3/14.
//  Copyright © 2019 Qiming. All rights reserved.
//

import Cocoa
import SnapKit
import Carbon

class ClipboardContentViewController : NSViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var loading = true {
        didSet {
            if !loading {
                NSAnimationContext.runAnimationGroup({ (context) in
                    context.duration = 0.1
                    context.allowsImplicitAnimation = true
                    self.imgPreview.animator().alphaValue = 0
                    self.textPreview.animator().alphaValue = 0
                    self.clipBoardHistoryTableView.animator().alphaValue = 1
                    self.emptyPrompt.animator().alphaValue = 0
                }, completionHandler: {
                })
            }
        }
    }
    
    var dataSource:[HistoryContent]!
    
    var sensitive = NSString.CompareOptions.caseInsensitive {
        didSet {
            self.sensitivePrompt.stringValue = self.sensitiveString
            self.sensitivePrompt.textColor = self.sensitiveColor
            self.onTextChange(note: nil)
        }
    }
    
    var sensitiveString:String {
        get {
            if self.sensitive == NSString.CompareOptions.caseInsensitive {
                return "不区分大小写 ->|"
            } else {
                return "区分大小写 ->|"
            }
        }
    }
    var sensitiveColor:NSColor {
        get {
            if self.sensitive == NSString.CompareOptions.caseInsensitive {
                return NSColor.lightGray
            } else {
                return NSColor.green
            }
        }
    }
    
    lazy var sensitivePrompt:NSTextField = {
        let txt = NSTextField()
        txt.alphaValue = 0.5
//        txt.alphaValue = 0
        txt.isBezeled = false
        txt.usesSingleLineMode = true
        txt.textColor = self.sensitiveColor
        txt.isEditable = false
        txt.drawsBackground = true
        txt.backgroundColor = .clear
        txt.stringValue = self.sensitiveString
        txt.font = NSFont.systemFont(ofSize: 12)
        return txt
    }()
    
    lazy var emptyPrompt:NSTextField = {
        let txt = NSTextField()
        txt.alphaValue = 0.5
        txt.isBezeled = false
        txt.usesSingleLineMode = true
        txt.textColor = NSColor(hexString: "FF8984")
        txt.isEditable = false
        txt.drawsBackground = true
        txt.backgroundColor = .clear
        txt.stringValue = "Loading"
        txt.alignment = .center
        txt.font = NSFont.systemFont(ofSize: 36)
        return txt
    }()
    
    lazy var searchField:PopoverSearchField = {
        var search = PopoverSearchField()
//        search.wantsLayer = true
//        search.plac
        search.textColor = NSColor(hexString: "FF8984")
        search.cancelAction = {
            MainApplication.shared.closeClipPopover()
        }
        search.copyAction = {
            let row = self.clipBoardHistoryTableView.selectedRow
            if row > self.dataSource.count {
                self.copy(content: self.dataSource[row])
            }
        }
        search.browseAction = {
            self.showFirstItem()
        }
        search.sensitiveAction = {
            if self.sensitive == NSString.CompareOptions.caseInsensitive {
                self.sensitive = NSString.CompareOptions.backwards
            } else {
                self.sensitive = NSString.CompareOptions.caseInsensitive
            }
        }
        search.dictAction = dict
        return search
    }()
    
    lazy var clipBoardHistoryTableView: ClipBoardTableView = {
        var tv = ClipBoardTableView()
        let column = NSTableColumn()
        tv.delegate = self
        tv.dataSource = self
        tv.headerView = nil
        tv.addTableColumn(column)
        tv.backgroundColor = .clear
        tv.upArrowAction = {
            self.view.window?.makeFirstResponder(self.searchField)
        }
        tv.resignAction = { event in
            if let chars = event.charactersIgnoringModifiers {
                self.searchField.stringValue = "\(chars)"
                self.onTextChange(note: nil)
            }
            self.view.window?.makeFirstResponder(self.searchField)
        }
        tv.tabAction = {
            if self.sensitive == NSString.CompareOptions.caseInsensitive {
                self.sensitive = NSString.CompareOptions.backwards
            } else {
                self.sensitive = NSString.CompareOptions.caseInsensitive
            }
        }
        tv.deleteAction = { //content in
            if self.searchField.stringValue.count > 0 {
                self.searchField.stringValue = ""
                self.view.window?.makeFirstResponder(self.searchField)
            } else {
                History.shared.remove(content: self.dataSource[tv.selectedRow])
            }
        }
        tv.target = self
        tv.doubleAction = #selector(doubleClick)
        return tv
    }()
    
    lazy var imgPreview: NSImageView = {
        let imgView = NSImageView(frame: NSRect.zero)
        imgView.imageAlignment = .alignCenter
        imgView.wantsLayer = true
        imgView.layer?.cornerRadius = 4
        imgView.alphaValue = 0
//        imgView.layer?.backgroundColor = PinkTheme.baseBGColor.cgColor
        return imgView
    }()
    
    lazy var textPreview: NSTextView = {
        
        let txt = NSTextView(frame: .zero)
        txt.wantsLayer = true
        txt.layer?.cornerRadius = 4
        txt.layer?.masksToBounds = true
        txt.isEditable = false
        txt.isSelectable = false
        txt.alphaValue = 0
        txt.textColor = .white
//        txt.textColor = PinkTheme.fontColor
//        txt.backgroundColor = PinkTheme.baseBGColor
        
//        let scrollView = NSScrollView()
//        scrollView.backgroundColor = .clear
//        scrollView.drawsBackground = false
//        scrollView.hasVerticalScroller = true
//        scrollView.documentView = txt
//        txt.snp.makeConstraints({ (make) in
//            make.width.equalTo(scrollView.contentSize.width)
//            make.height.equalTo(scrollView.contentSize.height)
//        })
        return txt
    }()

    lazy var mainView:PopoverRootView = {
        let view = PopoverRootView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { (make) in
            make.width.equalTo(PopoverSize.width)
            make.height.equalTo(PopoverSize.height)
        }
        view.addSubview(searchField)
        view.addSubview(imgPreview)
        view.addSubview(textPreview)
        view.addSubview(sensitivePrompt)
        view.addSubview(emptyPrompt)
        let scrollView = NSScrollView()
        scrollView.backgroundColor = .clear
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.documentView = self.clipBoardHistoryTableView
        view.addSubview(scrollView)
        searchField.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(PopoverSize.searchFieldHeight)
        }
        scrollView.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.width.equalTo(PopoverSize.scrollWidth)
            make.top.equalTo(PopoverSize.searchFieldHeight)
        }
        imgPreview.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView.snp.right).offset(4)
            make.right.bottom.equalToSuperview().offset(-6)
            make.top.equalTo(scrollView).offset(4)
        }
        textPreview.snp.makeConstraints { (make) in
            make.edges.equalTo(imgPreview)
        }
        sensitivePrompt.snp.makeConstraints({ (make) in
            make.right.equalToSuperview().offset(-3)
            make.top.equalToSuperview().offset(3)
        })
        emptyPrompt.snp.makeConstraints({ (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalTo(scrollView.snp.centerY).offset(-18)
        })
        return view
    }()
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        dataSource = History.shared.contentStorage
        view = mainView
    }
    
    func refresh() {
        //refresh
        dataSource = History.shared.contentStorage
        clipBoardHistoryTableView.reloadData()
        showFirstItem()
    }
    
    func showFirstItem() {
        if self.dataSource.count > 0 {
            self.view.window?.makeFirstResponder(self.clipBoardHistoryTableView)
            self.clipBoardHistoryTableView.selectRowIndexes(
                IndexSet(arrayLiteral: 0), byExtendingSelection: false)
            self.setPreview(content: self.dataSource[0])
            self.clipBoardHistoryTableView.scrollRowToVisible(0)
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        searchField.placeholderAttributedString = ["=。=","mua!","mua~","嘿嘿嘿"].randomElement()!.attributeString(using: NSColor(hexString: "FF8984"))
        refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onTextChange(note:)), name: NSControl.textDidChangeNotification, object: searchField)
    }
}
// MARK: Action
extension ClipboardContentViewController {
    @objc func onTextChange(note : NSNotification?) {
        NSLog("Search for %@", searchField.stringValue)
        if searchField.stringValue.isEmpty {
            self.dataSource = History.shared.contentStorage
        } else {
            self.dataSource = History.shared.contentStorage.filter { (content) -> Bool in
                let range = content.previewStr().range(
                    of: searchField.stringValue,
                    options: self.sensitive,
                    range: nil,
                    locale: nil
                )
                return (range != nil)
            }
        }
        clipBoardHistoryTableView.reloadData()
        clipBoardHistoryTableView.selectRowIndexes(
            IndexSet(arrayLiteral: 0), byExtendingSelection: false)
        if dataSource.count > 0 {
            setPreview(content: self.dataSource[0])
        } else {
            print("hide all")
            if searchField.stringValue.count > 0 {
                emptyPrompt.stringValue = "无搜索结果"
            } else {
                emptyPrompt.stringValue = "无历史记录"
            }
            hideAllPreview()
        }
    }
    override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case Int(kVK_Escape):
            MainApplication.shared.closeClipPopover()
            break
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
            self.searchField.becomeFirstResponder()
            break
        case Int(kVK_Return):
            let row = clipBoardHistoryTableView.selectedRow
            copy(content: self.dataSource[row])
            break
        default:
            super.keyDown(with: event)
        }
    }
}
// MARK: Preview Function
extension ClipboardContentViewController {
    func setPreview(content: HistoryContent) {
        if content.contentType == 0  { //data
            self.imgPreview.image = NSImage.init(data: content.data!)
            showPicPreview()
        } else {
            self.textPreview.string = content.string!
            self.showTextPreview()
        }
    }
    
    func hideAllPreview() {
        self.imgPreview.alphaValue = 0
        self.textPreview.alphaValue = 0
        self.clipBoardHistoryTableView.alphaValue = 0
        self.emptyPrompt.alphaValue = 0.5
    }
    
    private func showPicPreview() {
        self.textPreview.string = ""
        self.imgPreview.alphaValue = 1
        self.textPreview.alphaValue = 1
        view.bringSubviewToFront(self.imgPreview)
        self.clipBoardHistoryTableView.alphaValue = 1
        self.emptyPrompt.alphaValue = 0
    }
    
    private func showTextPreview() {
        self.imgPreview.image = nil
        self.imgPreview.alphaValue = 1
        self.textPreview.alphaValue = 1
        view.bringSubviewToFront(self.textPreview)
        self.clipBoardHistoryTableView.alphaValue = 1
        self.emptyPrompt.alphaValue = 0
    }
}
extension ClipboardContentViewController: NSTableViewDelegate, NSTableViewDataSource {

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return HistoryTableRowView()
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        var count = 0
        if let source = self.dataSource {
            count = source.count
        }
        return count
        
    }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 24
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "HistoryCell")
        var cellToReturn: PopOverCell!
        cellToReturn = tableView.makeView(withIdentifier: identifier, owner: self) as? PopOverCell
        if cellToReturn == nil {
            cellToReturn = PopOverCell()
            cellToReturn.identifier = identifier
            print("create.\(row)")
        }
        cellToReturn.identifier = identifier
        let data = self.dataSource[row]
        cellToReturn.textField?.textColor = .white
        cellToReturn.textField?.stringValue = data.previewStr().humanizedTitle()
        cellToReturn.colorView.layer?.backgroundColor = data.styleColor()
        cellToReturn.img.image = data.icon
        return cellToReturn
    }
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        setPreview(content: self.dataSource[row])
        return true
    }
    @objc func doubleClick() {
        let row = clipBoardHistoryTableView.clickedRow
        copy(content: self.dataSource[row])
    }
    func copy(content:HistoryContent) {
        if content.contentType == HistoryContentType.string.rawValue {
            Clipboard.shared.copy(content.string!)
        } else {
            Clipboard.shared.copy(content.data!)
        }
        print("copied.")
        MainApplication.shared.closeClipPopover()
    }
}
extension ClipboardContentViewController {
    func setTheme() {
//        view.wantsLayer = true
//        view.layer?.backgroundColor = theme.baseBGColor.cgColor
//        searchField.layer?.backgroundColor = theme.searchBGColor.cgColor
//        PopOverCell.lineColor = theme.lineColor
//        PopOverCell.bgColor = theme.baseBGColor
//        PopOverCell.textColor = theme.fontColor
//        imgPreview.layer?.backgroundColor = theme.previewBGColor.cgColor
////        imgPreview.simp
//        textPreview.layer?.backgroundColor = theme.previewBGColor.cgColor
//        textPreview.textColor = theme.baseBGColor
//        emptyPrompt.backgroundColor = theme.baseBGColor
    }
    func dict() {
        let urlString = "https://dict.youdao.com/suggest?q=\(self.searchField.stringValue)&le=eng&num=5&ver=&doctype=json&keyfrom=&model=&mid=&imei=&vendor=&screen=&ssid=&abtest="
        let session = URLSession.shared
        let req = URLRequest(url: URL.init(string: urlString)!)
        let task = session.dataTask(with: req) { (data, resp, err) in
            if err != nil {
                return
            }
            do {
                let obj = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                print(obj)
                let entries = ((obj as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>)["entries"] as! Array<Dictionary<String,String>>
                print(entries)
                var result = ""
                for i in 0..<entries.count {
                    let entry = entries[i]["entry"]
                    let explain = entries[i]["explain"]
                    result += "\(i + 1).\(entry!)\n\(explain!)\n"
                }
                DispatchQueue.main.async {
                    self.textPreview.string = result
                    self.showTextPreview()
                }
            } catch {
                print("json decode err.")
            }
        }
        task.resume()
    }
}
class PopOverClipboard: NSPopover {
    override init() {
        super.init()
        let controller = ClipboardContentViewController()
        self.contentViewController = controller
        self.animates = true
        self.appearance = appearance
    }
    required init?(coder: NSCoder) {
        return nil
    }
}
class PopoverRootView : NSView {
    override func viewDidMoveToWindow() {
        let aFrameView = self.window?.contentView?.superview
        let aBGView = PopoverBackgroundView.init(frame: (aFrameView?.bounds)!)
        aBGView.autoresizingMask = [.width, .height]
        aFrameView?.addSubview(aBGView, positioned: .below, relativeTo: aFrameView)
        super.viewDidMoveToWindow()
    }
}
class PopoverBackgroundView : NSView {
    override func draw(_ dirtyRect: NSRect) {
//        PinkTheme.baseBGColor.set()
//        __NSRectFill(self.bounds)
    }
}
