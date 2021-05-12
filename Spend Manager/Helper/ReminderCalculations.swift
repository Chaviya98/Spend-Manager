//
//  ReminderCalculations.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-04-25.
//

import Foundation

public class ReminderCalculations {
    
    public func getRemainingBudget(_ budget: Double, amount: Double) -> Int {
        var percentage = 100
        if budget > 0 {
            percentage = Int(100 - ((amount / budget) * 100))
        }
        return 100 - percentage
    }
    
}
