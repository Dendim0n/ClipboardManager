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

class PopOverClipboard: NSPopover {
    override init() {
        super.init()
        self.contentViewController = ClipboardContentViewController()
        self.animates = true
//        let appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
//        appearance?.allowsVibrancy = true
        self.appearance = appearance
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class ClipboardContentViewController : NSViewController {
    
    var dataSource:[HistoryContent]!
    
    lazy var searchField:PopoverSearchField = {
        var search = PopoverSearchField()
        search.cancelAction = {
            MainApplication.shared.closeClipPopover()
        }
        search.copyAction = {
            let row = self.clipBoardHistoryTableView.selectedRow
            self.copy(content: self.dataSource[row])
        }
        return search
    }()
    
    lazy var clipBoardHistoryTableView: NSTableView = {
        var tv = NSTableView()
        let column = NSTableColumn()
        tv.delegate = self
        tv.dataSource = self
        tv.headerView = nil
        tv.addTableColumn(column)
        tv.backgroundColor = .clear
        tv.target = self
        tv.doubleAction = #selector(doubleClick)
        return tv
    }()
    
    lazy var imgPreview: NSImageView = {
        let imgView = NSImageView(frame: NSRect.zero)
        imgView.imageAlignment = .alignCenter
        return imgView
    }()
    
    lazy var textPreview: NSTextField = {
        let txt = NSTextField(frame: .zero)
        txt.layer?.shadowRadius = 4
        txt.layer?.masksToBounds = true
        txt.shadow = NSShadow()
        txt.isEditable = false
        txt.isSelectable = false
        return txt
    }()
    
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
//        self.view.setneed
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.1
            self.imgPreview.animator().alphaValue = 0
            self.textPreview.animator().alphaValue = 0
            self.clipBoardHistoryTableView.animator().alphaValue = 0
//            self.view.snp.updateConstraints({ (make) in
//                make.height.equalTo(54)
//            })
//            MainApplication.shared.popoverClip.contentSize = CGSize(width: 360, height: 54)
        }, completionHandler: {
            completion()
        })
    }
    
    private func showPicPreview() {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 0.1
        self.imgPreview.animator().alphaValue = 1
        self.textPreview.animator().alphaValue = 0
        self.clipBoardHistoryTableView.animator().alphaValue = 1
        NSAnimationContext.endGrouping()
    }
    
    private func showTextPreview() {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 0.1
        self.imgPreview.animator().alphaValue = 0
        self.textPreview.animator().alphaValue = 1
        self.clipBoardHistoryTableView.animator().alphaValue = 1
        NSAnimationContext.endGrouping()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        dataSource = History.shared.contentStorage
        view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.addConstraint(NSLayoutConstraint(
//            item: view, attribute: .width, relatedBy: .equal,
//            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 360))
        view.snp.makeConstraints { (make) in
            make.width.equalTo(360)
            make.height.equalTo(240)
        }
//        view.addConstraint(NSLayoutConstraint(
//            item: view, attribute: .height, relatedBy: .equal,
//            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 240))
        view.addSubview(searchField)
        view.addSubview(imgPreview)
        view.addSubview(textPreview)
        let scrollView = NSScrollView()
        scrollView.backgroundColor = .clear
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.documentView = self.clipBoardHistoryTableView
        view.addSubview(scrollView)
        searchField.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(64)
        }
        scrollView.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.width.equalTo(180)
            make.top.equalTo(self.searchField.snp.bottom)
        }
        imgPreview.snp.makeConstraints { (make) in
            make.left.equalTo(scrollView.snp.right)
            make.right.bottom.equalToSuperview()
            make.top.equalTo(scrollView)
        }
        textPreview.snp.makeConstraints { (make) in
            make.edges.equalTo(imgPreview).inset(NSEdgeInsetsMake(4, 4, 4, 4))
        }
    }
    override func viewWillAppear() {
        super.viewWillAppear()
        //refresh
        dataSource = History.shared.contentStorage
        clipBoardHistoryTableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onTextChange(note:)), name: NSControl.textDidChangeNotification, object: searchField)
    }
    
    @objc func onTextChange(note : NSNotification) {
//        NSLog("Search for %@", searchField.stringValue)
        if searchField.stringValue.isEmpty {
            self.dataSource = History.shared.contentStorage
        } else {
            self.dataSource = self.dataSource.filter { (content) -> Bool in
                let range = content.previewStr().range(
                    of: searchField.stringValue,
                    options: .caseInsensitive,
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
            print("keycode = \(event.keyCode)")
            self.searchField.becomeFirstResponder()
            break
        case Int(kVK_Return):
            let row = clipBoardHistoryTableView.selectedRow
            print("row = \(row)")
            copy(content: self.dataSource[row])
            break
        case Int(kVK_UpArrow):
            let row = clipBoardHistoryTableView.selectedRow
            if row == 0 {
                self.searchField.becomeFirstResponder()
            } else {
                super.keyDown(with: event)
            }
        default:
            super.keyDown(with: event)
        }
    }
}
extension ClipboardContentViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.dataSource.count
    }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 24
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "HistoryCell")
        var cellToReturn: PopOverCell!
        if let cell = tableView.makeView(withIdentifier: identifier, owner: self) as? PopOverCell {
            cellToReturn = cell
            cellToReturn.textField?.stringValue = self.dataSource[row].previewStr()
        } else {
            cellToReturn = PopOverCell()
            cellToReturn.identifier = identifier
            cellToReturn.textField?.textColor = .white
            cellToReturn.textField?.stringValue = self.dataSource[row].previewStr()
        }
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
