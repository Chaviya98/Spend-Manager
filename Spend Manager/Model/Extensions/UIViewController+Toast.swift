//
//  UIViewController+Toast.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-04-25.
//

import Foundation
import UIKit

extension UIViewController{
func showToast(message : String, seconds: Double){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .systemPurple
        alert.view.alpha = 0.3
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
 }
