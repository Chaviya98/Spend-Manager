//
//  AddCategoryViewController.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-04-07.
//

import Foundation
import UIKit
import CoreData

class AddCategoryViewController: UITableViewController, UITextViewDelegate {
    
    var editingMode: Bool = false
    let colors:Colors = Colors()
    var categories: [NSManagedObject] = []
    var buttonArray : [UIButton] = []
    var colorsArray : [String] = ["#DBD9D9","#D3B5E8","#EDD8BE","#C3EBC3","#ECCBF2","#C3E6E5","#E7EBC5"]
    
    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var budgetTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var backgroundColorbtn1: UIButton!
    @IBOutlet weak var backgroundColorbtn2: UIButton!
    @IBOutlet weak var backgroundColorbtn3: UIButton!
    @IBOutlet weak var backgroundColorbtn4: UIButton!
    @IBOutlet weak var backgroundColorbtn5: UIButton!
    @IBOutlet weak var backgroundColorbtn6: UIButton!
    @IBOutlet weak var backgroundColorbtn7: UIButton!
    @IBOutlet weak var addbtn: UIBarButtonItem!
    
    var colorCode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if !editingMode {
            // Settings the placeholder for notes UITextView
            notesTextView.delegate = self
            notesTextView.text = NSLocalizedString("noteTextVIewPlaceHolder", comment: "")
            notesTextView.textColor = UIColor.lightGray
            colorCode = "#DBD9D9"
            selectBackgroundColorButton(colorCode:self.colorCode)
        }
        
        configureView()
        addButtonEnability()
    }
    
    
    func setupUI() {
        backgroundColorbtn1.backgroundColor = colors.hexStringToUIColor(hex: "#DBD9D9")
        backgroundColorbtn2.backgroundColor = colors.hexStringToUIColor(hex: "#D3B5E8")
        backgroundColorbtn3.backgroundColor = colors.hexStringToUIColor(hex: "#EDD8BE")
        backgroundColorbtn4.backgroundColor = colors.hexStringToUIColor(hex: "#C3EBC3")
        backgroundColorbtn5.backgroundColor = colors.hexStringToUIColor(hex: "#ECCBF2")
        backgroundColorbtn6.backgroundColor = colors.hexStringToUIColor(hex: "#C3E6E5")
        backgroundColorbtn7.backgroundColor = colors.hexStringToUIColor(hex: "#E7EBC5")
        
        buttonArray.append(backgroundColorbtn1)
        buttonArray.append(backgroundColorbtn2)
        buttonArray.append(backgroundColorbtn3)
        buttonArray.append(backgroundColorbtn4)
        buttonArray.append(backgroundColorbtn5)
        buttonArray.append(backgroundColorbtn6)
        buttonArray.append(backgroundColorbtn7)
        
        
        if editingMode {
            colorCode = (editingCategory?.color)!
            selectBackgroundColorButton(colorCode: colorCode)
        }
    }
    
    var editingCategory: Category? {
        didSet {
            // Update the view.
            editingMode = true
            configureView()
        }
    }
    
    
    func configureView() {
        if editingMode {
            self.navigationItem.title = NSLocalizedString("editCategoryHeaderTitle", comment: "")
            self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("editCategorySaveButtonTitle", comment: "")
        }
        
        
        if editingCategory != nil {
            if let categoryName = categoryNameTextField {
                categoryName.text = editingCategory?.name
            }
            if let budgetValue = budgetTextField {
                budgetValue.text = String(editingCategory!.budget)
                
            }
            if let notes = notesTextView {
                notes.text = editingCategory?.notes
            }
            
            colorCode = (editingCategory?.color)!
            //selectBackgroundColorButton(colorCode:self.colorCode)
        }
    }
    
    //to select the button relavent to the color code
    func selectBackgroundColorButton(colorCode:String) {
 
        for (index, color) in colorsArray.enumerated() {
            if color == colorCode {
                buttonArray[index].layer.borderWidth = 1.5
            } else {
                buttonArray[index].layer.borderWidth = 0
            }
        }
    }
    // Check if the required fields are empty or not
    func validateUserInputs() -> Bool {
        if !(categoryNameTextField.text?.isEmpty)! && !(budgetTextField.text?.isEmpty)! && !(notesTextView.text == "") && !(notesTextView.text?.isEmpty)! {
            return true
        }
        return false
    }
    
    func addButtonEnability() {
        if validateUserInputs() {
            addbtn.isEnabled = true;
        } else {
            addbtn.isEnabled = false;
        }
    }
    
    
    // to dismiss popover
    func dismissAddProjectPopOver() {
        dismiss(animated: true, completion: nil)
        popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)
    }
    
    @IBAction func btnPressedCancel(_ sender: UIBarButtonItem) {
        dismissAddProjectPopOver()
    }
    
    @IBAction func btnPressedBackgroundColor(_ sender: UIButton) {
        colorCode = colors.hexStringFromColor(color:sender.backgroundColor!)
        
        for (index,button) in buttonArray.enumerated() {
            if button.tag == sender.tag {
                button.layer.borderWidth = 1.5
            } else {
                button.layer.borderWidth = 0
            }
        }
    }
    
    
    @IBAction func btnPressedAdd(_ sender: UIBarButtonItem) {
        
        if validateUserInputs() {
            let categoryName = categoryNameTextField.text
            let budgetValue = Double(budgetTextField.text!)
            let notes = notesTextView.text
            let backgroundColor = colorCode
            
            
            guard let appDelegate =
                    UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Category", in: managedContext)!
            
            var category = NSManagedObject()
            
            if editingMode {
                category = (editingCategory as? Category)!
            } else {
                category = NSManagedObject(entity: entity, insertInto: managedContext)
            }
            
            
            category.setValue(categoryName, forKeyPath: "name")
            category.setValue(budgetValue, forKeyPath: "budget")
            category.setValue(notes, forKeyPath: "notes")
            category.setValue(0, forKeyPath: "oftenSelectedCount")
            category.setValue(backgroundColor, forKeyPath: "color")
            
            do {
                try managedContext.save()
                categories.append(category)
            } catch _ as NSError {
                displayAlertView(alertTitle: Alerts.CommonAlert.TITLE, alertDescription: Alerts.CommonAlert.MESSAGE)
            }
            
        } else {
            displayAlertView(alertTitle: Alerts.InvalidParameters.TITLE, alertDescription: Alerts.InvalidParameters.MESSAGE)
        }
        
        dismissAddProjectPopOver()
    }
    
    
    
    @IBAction func handleCategoryNameChange(_ sender: UITextField) {
        addButtonEnability()
    }
    
    @IBAction func handleBudgetValueChange(_ sender: UITextField) {
        addButtonEnability()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        addButtonEnability()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        addButtonEnability()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = NSLocalizedString("noteTextVIewPlaceHolder", comment: "")
            textView.textColor = UIColor.lightGray
        }
        addButtonEnability()
    }
    
}

// MARK: - UITableViewDelegate
extension AddCategoryViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            categoryNameTextField.becomeFirstResponder()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            budgetTextField.becomeFirstResponder()
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            backgroundColorbtn1.becomeFirstResponder()
            backgroundColorbtn2.becomeFirstResponder()
            backgroundColorbtn3.becomeFirstResponder()
            backgroundColorbtn4.becomeFirstResponder()
            backgroundColorbtn5.becomeFirstResponder()
            backgroundColorbtn6.becomeFirstResponder()
            backgroundColorbtn7.becomeFirstResponder()
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            notesTextView.becomeFirstResponder()
        }
      
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
}
