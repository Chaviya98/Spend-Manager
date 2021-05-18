//
//  Alerts.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-04-07.
//

import Foundation
struct Alerts {

    struct CommonAlert {
        static let TITLE = "Something went wrong !"
        static let MESSAGE = "Please try again later."
        static let ACTION_TITLE = "OK"
    }
    
    struct InvalidParameters {
        static let TITLE = "Adding Failed !"
        static let MESSAGE = "Please enter valid inputs."
    }
    
    struct failedCalendarEvent {
        static let TITLE = "Event Creation Failed !"
        static let MESSAGE = "Calendar event could not be created!. Please try again later." 
    }
}
