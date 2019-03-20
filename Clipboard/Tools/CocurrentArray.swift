//
//  CocurrentArray.swift
//  Clipboard
//
//  Created by 任岐鸣 on 2019/3/15.
//  Copyright © 2019 Qiming. All rights reserved.
//

import Dispatch

class SharedSynchronizedArray<T> {
    var array = [T]()
    let operationQueue = DispatchQueue(label: "SharedSynchronizedArray")
    
    func append(_ newElement: T) {
        operationQueue.sync {
            array.append(newElement)
        }
    }
}

public struct ConcurrentSequence<Base, Element>: Sequence
where Base: Sequence, Element == Base.Iterator.Element {
    let base: Base
    
    public func makeIterator() -> Base.Iterator {
        return base.makeIterator()
    }
    
    public func map<T>(_ transform: @escaping (Element) -> T) -> [T] {
        let group = DispatchGroup()
        
        let resultsStorageQueue = DispatchQueue(label: "resultStorageQueue")
        let results = SharedSynchronizedArray<T>()
        
        let processingQueue = DispatchQueue(
            label: "processingQueue",
            attributes: [.concurrent]
        )
        
        for element in self {
            group.enter()
//            print("Entered DispatchGroup for \(element)")
            
            var result: T?
            let workItem = DispatchWorkItem{ result = transform(element) }
            
            processingQueue.async(execute: workItem)
            
            resultsStorageQueue.async {
                workItem.wait()
                guard let unwrappedResult = result else {
//                    fatalError("The work item was completed, but the result wasn't set!")
                    return
                }
                results.append(unwrappedResult)
                
                
                group.leave()
//                print("Exited DispatchGroup for \(element)")
            }
        }
//        print("Started Waiting on DispatchGroup")
        group.wait()
//        print("DispatchGroup done")
        
        return results.array
    }
    
    
}

public extension Sequence {
    public var parallel: ConcurrentSequence<Self, Iterator.Element> {
        return ConcurrentSequence(base: self)
    }
}
