//
//  Colors.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-03-31.
//

import Foundation
import UIKit

public class Colors {
    public func getProgressGradient(_ percentage: Int, negative: Bool = false) -> [UIColor] {
        let _default: [UIColor] = [UIColor.red, UIColor.orange]
        
        if !negative {
            if percentage <= 33 {
                return [UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.00), UIColor(red: 255/255, green: 69/255, blue: 69/255, alpha: 1.00)]
            } else if percentage <= 66 {
                return [UIColor(red: 255/255, green: 126/255, blue: 0/255, alpha: 1.00), UIColor(red: 255/255, green: 155/255, blue: 57/255, alpha: 1.00)]
            } else if percentage <= 100 {
                return [UIColor(red: 50/255, green: 200/255, blue: 0/255, alpha: 1.00), UIColor(red: 151/255, green: 255/255, blue: 49/255, alpha: 1.00)]
            }
            return _default
        } else {
            if percentage <= 33 {
                return [UIColor(red: 50/255, green: 200/255, blue: 0/255, alpha: 1.00), UIColor(red: 151/255, green: 255/255, blue: 49/255, alpha: 1.00)]
            } else if percentage <= 66 {
                return [UIColor(red: 255/255, green: 126/255, blue: 0/255, alpha: 1.00), UIColor(red: 255/255, green: 155/255, blue: 57/255, alpha: 1.00)]
            } else if percentage <= 100 {
                return [UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.00), UIColor(red: 255/255, green: 69/255, blue: 69/255, alpha: 1.00)]
            }
            return _default
        }
        return _default
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
