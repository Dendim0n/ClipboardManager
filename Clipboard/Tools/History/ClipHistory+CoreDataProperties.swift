//
//  ClipHistory+CoreDataProperties.swift
//  
//
//  Created by 任岐鸣 on 2019/4/1.
//
//

import Foundation
import CoreData


extension ClipHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClipHistory> {
        return NSFetchRequest<ClipHistory>(entityName: "ClipHistory")
    }

    @NSManaged public var type: Int32
    @NSManaged public var data: NSData?
    @NSManaged public var string: String?
    @NSManaged public var source: String?
    @NSManaged public var icon: NSData?

}
