//
//  Category+CoreDataProperties.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-03-31.
//

import Foundation
import CoreDate
import UIKit

extension Category {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category>{
        return NSFetchRequest<Category>(entityName: "Category")
    }
    
    @NSManaged public var name: String
    @NSManaged public var budget: Double
    @NSManaged public var colour: UIColor
    @NSManaged public var notes: String
 
    
}

extension Category {
    
    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)
}
