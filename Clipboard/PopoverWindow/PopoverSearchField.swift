//
//  PopoverSearchField.swift
//  Clipboard
//
//  Created by 任岐鸣 on 2019/3/14.
//  Copyright © 2019 Qiming. All rights reserved.
//

import Cocoa
import Carbon
import HotKey
//TODO: 上下键绑定。
typealias keyOperation = () -> Void
class PopoverSearchField: NSSearchField,NSSearchFieldDelegate {
    var copyAction:keyOperation?
    var cancelAction:keyOperation?
    var browseAction:keyOperation?
    private var eventHandler: EventHandlerRef?
    private let eventSpecs = [
        EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventRawKeyDown)),
        EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventRawKeyRepeat))
    ]
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.focusRingType = .none
        self.delegate = self
        self.font = NSFont.systemFont(ofSize: 16)
//        self.isBordered = false
//        self.alignment = .center
//        self.action = #selector(customAction)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    override func keyDown(with event: NSEvent) {
//        super.keyDown(with: event)
//    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(insertNewline(_:)) {
//            textView.insertNewlineIgnoringFieldEditor(self)
            if self.copyAction != nil {
                self.copyAction!()
            }
//            return false
        }
        if commandSelector == #selector(moveDown(_:)) {
            if self.browseAction != nil {
                self.browseAction!()
            }
        }
        return false
    }
//    @objc func customAction() {
//        print(self.stringValue)
//    }
    override func cancelOperation(_ sender: Any?) {
        guard self.stringValue.count == 0 else {
            super.cancelOperation(sender)
            return
        }
        if cancelAction != nil {
            cancelAction!()
        }
    }
   
}
extension PopoverSearchField {
    private func processInterceptedEvent(_ eventRef: EventRef) -> Bool {
        let firstResponder = window?.firstResponder
        if firstResponder == self || firstResponder == self.currentEditor() {
            return false
        }
        
        guard let event = NSEvent(eventRef: UnsafeRawPointer(eventRef)) else {
            return false
        }
        
        if event.type != NSEvent.EventType.keyDown {
            return false
        }
        
        if let key = Key(carbonKeyCode: UInt32(event.keyCode)) {
            if Keys.shouldPassThrough(key) {
                return false
            }
            
            let query = self.stringValue
            if key == Key.delete {
                if query.isEmpty == false {
                    //                    setQuery(String(query.dropLast()))
                }
                return true
            }
            
            let modifierFlags = event.modifierFlags
            if modifierFlags.contains(.command) || modifierFlags.contains(.control) || modifierFlags.contains(.option) {
                return false
            }
            
            if let chars = event.charactersIgnoringModifiers {
                if chars.count == 1 {
                    //                    setQuery("\(query)\(chars)")
                    return true
                }
            }
        }
        return false
    }
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        if window != nil {
            if let dispatcher = GetEventDispatcherTarget() {
                // Create pointer to our event processer.
                let eventProcessorPointer = UnsafeMutablePointer<Any>.allocate(capacity: 1)
                eventProcessorPointer.initialize(to: processInterceptedEvent)
                
                let eventHandlerCallback: EventHandlerUPP = { _, eventRef, userData in
                    guard let event = eventRef else { return noErr }
                    guard let callbackPointer = userData else { return noErr }
                    
                    // Call our event processor from pointer.
                    let eventProcessPointer = UnsafeMutablePointer<(EventRef) -> (Bool)>(OpaquePointer(callbackPointer))
                    let eventProcessed = eventProcessPointer.pointee(event)
                    
                    if eventProcessed {
                        return noErr
                    } else {
                        return OSStatus(Carbon.eventNotHandledErr)
                    }
                }
                
                InstallEventHandler(dispatcher, eventHandlerCallback, 2, eventSpecs, eventProcessorPointer, &eventHandler)
            }
        } else {
            RemoveEventHandler(eventHandler)
            //            setQuery("")
            self.stringValue = ""
        }
    }
}
