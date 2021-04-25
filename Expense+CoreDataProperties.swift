//
//  Expense+CoreDataProperties.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-04-21.
//
//

import Foundation
import CoreData


extension Expense {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        return NSFetchRequest<Expense>(entityName: "Expense")
    }

    @NSManaged public var addToCalendar: Bool
    @NSManaged public var amount: Double
    @NSManaged public var calendarIdentifier: String?
    @NSManaged public var endDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var occurrence: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var category: Category?

}

extension Expense : Identifiable {

}
