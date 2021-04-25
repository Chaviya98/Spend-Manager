//
//  NotesPopUpController.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-04-09.
//

import Foundation
import UIKit

class NotesPopoverController: UIViewController {
    
    @IBOutlet weak var notesTextView: UITextView!
    
    var notes: String? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    func configureView() {
        if let notes = notes {
            if let notesTextView = notesTextView {
                notesTextView.text = notes
            }
        }
    }
}
