//
//  Expenses+CoreDataProperties.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-03-31.
//

import Foundation
import CoreDate
import UIKit

extension Expenses {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expenses>{
        return NSFetchRequest<Expenses>(entityName: "Expenses")
    }
    
    @NSManaged public var dueDate: NSDate
    @NSManaged public var startDate: NSDate
    @NSManaged public var amount: Double
    @NSManaged public var occurrence: String
    @NSManaged public var notes: String
    @NSManaged public var reminderFlag: Bool
    @NSManaged public var name: String
    @NSManaged public var category: Category?
    
    
}
