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
    var colorsArray : [String] = ["#dbd9d9","#d3b5e8","#edd8be","#c3ebc3","#eccbf2","#c3e6e5","#e7ebc5"]
    
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
            notesTextView.delegate = self
            notesTextView.text = "Notes"
            colorCode = "#dbd9d9"
            selectBackgroundColorButton(colorCode:self.colorCode)
        }
        
        configureView()
        addButtonEnability()
    }
    
    
    func setupUI() {
        backgroundColorbtn1.backgroundColor = colors.hexStringToUIColor(hex: "#dbd9d9")
        backgroundColorbtn2.backgroundColor = colors.hexStringToUIColor(hex: "#d3b5e8")
        backgroundColorbtn3.backgroundColor = colors.hexStringToUIColor(hex: "#edd8be")
        backgroundColorbtn4.backgroundColor = colors.hexStringToUIColor(hex: "#c3ebc3")
        backgroundColorbtn5.backgroundColor = colors.hexStringToUIColor(hex: "#eccbf2")
        backgroundColorbtn6.backgroundColor = colors.hexStringToUIColor(hex: "#c3e6e5")
        backgroundColorbtn7.backgroundColor = colors.hexStringToUIColor(hex: "#e7ebc5")
        
        buttonArray.append(backgroundColorbtn1)
        buttonArray.append(backgroundColorbtn2)
        buttonArray.append(backgroundColorbtn3)
        buttonArray.append(backgroundColorbtn4)
        buttonArray.append(backgroundColorbtn5)
        buttonArray.append(backgroundColorbtn6)
        buttonArray.append(backgroundColorbtn7)
        
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
            self.navigationItem.title = "Edit Project"
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        
        print(buttonArray.count)
        
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
            selectBackgroundColorButton(colorCode:self.colorCode)
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
            category.setValue(backgroundColor, forKeyPath: "color")
            
            
            print(category)
            
            do {
                try managedContext.save()
                categories.append(category)
            } catch _ as NSError {
                displayAlertView(alertTitle: "Error", alertDescription: "An error occured while saving the project.")
            }
            
        } else {
            displayAlertView(alertTitle: "Error", alertDescription: "Please fill the required fields.")
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
            textView.text = "Notes"
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
