////
////  PopOverStatusMenu.swift
////  Clipboard
////
////  Created by 任岐鸣 on 2019/3/14.
////  Copyright © 2019 Qiming. All rights reserved.
////
//
//import Cocoa
//
//class PopOverStatusMenu: NSPopover {
//    override init() {
//        super.init()
//        self.contentViewController = StatusMenuContentViewController()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//class DummyControl : NSControl {
//    override func mouseDown(with: NSEvent) {
//        superview!.mouseDown(with: with)
//        sendAction(action, to: target)
//    }
//}
//class StatusMenuContentViewController : NSViewController {
//
//    var searchField : NSSearchField!
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    override func loadView() {
//        view = NSView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.addConstraint(NSLayoutConstraint(
//            item: view, attribute: .width, relatedBy: .equal,
//            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 280))
//        view.addConstraint(NSLayoutConstraint(
//            item: view, attribute: .height, relatedBy: .equal,
//            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200))
//
//        searchField = NSSearchField()
//        searchField.translatesAutoresizingMaskIntoConstraints = false
//        searchField.focusRingType = .none
//        view.addSubview(searchField)
//        view.addConstraints(NSLayoutConstraint.constraints(
//            withVisualFormat: "H:|-(20)-[searchField]-(20)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["searchField":searchField]))
//        view.addConstraints(NSLayoutConstraint.constraints(
//            withVisualFormat: "V:|-(20)-[searchField(==30)]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["searchField":searchField]))
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
////        NotificationCenter.default.addObserver(self, selector: <#T##Selector#>, name: <#T##NSNotification.Name?#>, object: <#T##Any?#>)
////        NotificationCenter.default.addObserver(self, selector: #selector(onTextChange:), name: NSControl.textDidChangeNotification, object: searchField)
//    }
//
//    @objc func onTextChange(note : NSNotification) {
//        NSLog("Search for %@", searchField.stringValue)
//    }
//}
