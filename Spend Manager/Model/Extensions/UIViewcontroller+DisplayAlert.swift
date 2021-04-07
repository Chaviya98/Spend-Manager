//
//  UIViewcontroller+DisplayAlert.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-04-07.
//

import Foundation
import UIKit

extension UIViewController {
    func displayAlertView(alertTitle: String, alertDescription: String) {
        let alertController = UIAlertController(title: alertTitle, message: alertDescription, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: Alerts.CommonAlert.ACTION_TITLE, style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
