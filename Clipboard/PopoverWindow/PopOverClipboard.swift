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
        txt.textColor = .white
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
            if self.dataSource.count > 0 {
                self.view.window?.makeFirstResponder(self.clipBoardHistoryTableView)
                self.clipBoardHistoryTableView.selectRowIndexes(
                    IndexSet(arrayLiteral: 0), byExtendingSelection: false)
                self.setPreview(content: self.dataSource[0])
            }
        }
        search.sensitiveAction = {
            if self.sensitive == NSString.CompareOptions.caseInsensitive {
                self.sensitive = NSString.CompareOptions.backwards
            } else {
                self.sensitive = NSString.CompareOptions.caseInsensitive
            }
        }
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
        tv.sensitiveAction = {
            if self.sensitive == NSString.CompareOptions.caseInsensitive {
                self.sensitive = NSString.CompareOptions.backwards
            } else {
                self.sensitive = NSString.CompareOptions.caseInsensitive
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
        return imgView
    }()

    lazy var mainView:NSView = {
        let view = NSView()
        //background color?
        //        view.wantsLayer = true
        //        view.layer?.backgroundColor = NSColor.systemPink.cgColor
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
    
    lazy var textPreview: NSTextField = {
        let txt = NSTextField(frame: .zero)
        txt.wantsLayer = true
        txt.layer?.cornerRadius = 4
        txt.layer?.shadowRadius = 4
        txt.layer?.masksToBounds = true
        txt.shadow = NSShadow()
        txt.isEditable = false
        txt.isSelectable = false
        txt.alphaValue = 0
        return txt
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
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        searchField.placeholderString = ["=。=","mua!","mua~","嘿嘿嘿"].randomElement()
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
            emptyPrompt.stringValue = "无搜索结果"
            hideAllPreview(completion: {})
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
            self.textPreview.stringValue = content.string!
            self.showTextPreview()
        }
    }
    
    private func hideAllPreview(completion:@escaping (()->Void)) {
        
        self.imgPreview.alphaValue = 0
        self.textPreview.alphaValue = 0
        self.clipBoardHistoryTableView.alphaValue = 0
        self.emptyPrompt.alphaValue = 1
        
//        NSAnimationContext.runAnimationGroup({ (context) in
//            context.duration = 0.1
//            context.allowsImplicitAnimation = true
//            self.imgPreview.animator().alphaValue = 0
//            self.textPreview.animator().alphaValue = 0
//            self.clipBoardHistoryTableView.animator().alphaValue = 0
//            self.emptyPrompt.animator().alphaValue = 1
////            self.view.snp.updateConstraints({ (make) in
////                make.height.equalTo(PopoverSize.searchFieldHeight)
////            })
////            self.view.layoutSubtreeIfNeeded()
////            MainApplication.shared.popoverClip.contentSize = CGSize(width: 360, height: PopoverSize.searchFieldHeight)
//        }, completionHandler: {
//            completion()
//        })
    }
    
    private func showPicPreview() {
        self.imgPreview.alphaValue = 1
        self.textPreview.alphaValue = 0
        self.clipBoardHistoryTableView.alphaValue = 1
        self.emptyPrompt.alphaValue = 0
//        NSAnimationContext.runAnimationGroup({ (context) in
//            context.duration = 0.1
//            context.allowsImplicitAnimation = true
//
////            self.view.snp.updateConstraints({ (make) in
////                make.height.equalTo(PopoverSize.height)
////            })
////            MainApplication.shared.popoverClip.contentSize = CGSize(width: 360, height: PopoverSize.height)
////            self.view.layoutSubtreeIfNeeded()
//        }, completionHandler: {
//
//        })
    }
    
    private func showTextPreview() {
        self.imgPreview.alphaValue = 0
        self.textPreview.alphaValue = 1
        self.clipBoardHistoryTableView.alphaValue = 1
        self.emptyPrompt.alphaValue = 0
//        NSAnimationContext.runAnimationGroup({ (context) in
//            context.duration = 0.1
//            context.allowsImplicitAnimation = true
//
////            self.view.snp.updateConstraints({ (make) in
////                make.height.equalTo(PopoverSize.height)
////            })
////            MainApplication.shared.popoverClip.contentSize = CGSize(width: 360, height: PopoverSize.height)
////            self.view.layoutSubtreeIfNeeded()
//        }, completionHandler: {
//
//        })
    }
}
extension ClipboardContentViewController: NSTableViewDelegate, NSTableViewDataSource {

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return HistoryTableRowView()
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let source = self.dataSource {
            return source.count
        } else {
            return 0
        }
    }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 24
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "HistoryCell")
        var cellToReturn: PopOverCell!
        cellToReturn = tableView.makeView(withIdentifier: identifier, owner: self) as? PopOverCell ?? PopOverCell()
        cellToReturn = PopOverCell()
        cellToReturn.identifier = identifier
//        if loading {
//            cellToReturn.textField?.stringValue = "[Loading...]"
//            return cellToReturn
//        }
        let data = self.dataSource[row]
        cellToReturn.textField?.textColor = .white
        cellToReturn.textField?.stringValue = data.previewStr().humanizedTitle()
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

class PopOverClipboard: NSPopover {
    override init() {
        super.init()
        self.contentViewController = ClipboardContentViewController()
        self.animates = true
        self.appearance = appearance
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
