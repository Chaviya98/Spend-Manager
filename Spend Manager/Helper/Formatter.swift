//
//  Formatter.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-03-31.
//

import Foundation

public class Formatter {
    public func formatDate(_ date : Date) -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
}
