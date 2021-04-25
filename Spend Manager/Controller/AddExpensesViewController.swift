//
//  AddExpensesViewController.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-04-07.
//

import Foundation
import UIKit
import CoreData
import EventKit
import UserNotifications

enum OccurrenceTypes: Int {
    case One, Daliy, Weekly, Monthly
}

class AddExpensesViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate {
    
    
    var expenses: [NSManagedObject] = []
    let dateFormatter : Formatter = Formatter()
    var taskProgressPickerVisible = false
    var datePickerVisible = false
    var selectedCategory: Category?
    var editingMode: Bool = false
    var occurrenceType = ""
    let now = Date()
    
    let formatter: Formatter = Formatter()
    
    
    @IBOutlet weak var expenseNameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var addToCalendarSwitch: UISwitch!
    @IBOutlet weak var occurrenceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if !editingMode {
            // Set start date to current
            datePicker.minimumDate = now
            dateLabel.text = formatter.formatDate(now)
            
            
            // Settings the placeholder for notes UITextView
            notesTextView.delegate = self
            notesTextView.text = "Notes"
            notesTextView.textColor = UIColor.lightGray
            
            occurrenceType = "One off"
        }
        
        
        configureView()
        // Disable add button
        addButtonEnability()
    }
    var editingExpense: Expense? {
        didSet {
            // Update the view.
            editingMode = true
            configureView()
        }
    }
    
    func configureView() {
        if editingMode {
            self.navigationItem.title = "Edit Task"
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        
        if let expense = editingExpense {
            if let textField = expenseNameTextField {
                textField.text = expense.name
            }
            if let textField = amountTextField {
                textField.text = String(expense.amount)
            }
            if let textView = notesTextView {
                textView.text = expense.notes
            }
            if let label = dateLabel {
                label.text = formatter.formatDate(expense.endDate! as Date)
            }
            if let datePicker = datePicker {
                datePicker.date = expense.endDate! as Date
            }
            if let uiSwitch = addToCalendarSwitch {
                uiSwitch.setOn(expense.addToCalendar, animated: true)
            }
            
            setSegmentSelectedValue(occurrence: expense.occurrence!)
        }
    }
    
    @IBAction func handleDateChange(_ sender: UIDatePicker) {
        dateLabel.text = formatter.formatDate(sender.date)
        
    }
    
    private func setSegmentSelectedValue(occurrence: String){
        
        if (occurrence == "One") {
            occurrenceSegmentedControl.selectedSegmentIndex = 0
        } else  if (occurrence == "Daliy"){
            occurrenceSegmentedControl.selectedSegmentIndex = 1
        } else if (occurrence == "Weekly"){
            occurrenceSegmentedControl.selectedSegmentIndex = 2
        } else if (occurrence == "Monthly"){
            occurrenceSegmentedControl.selectedSegmentIndex = 3
        }
    }
    
    @IBAction func occurrenceSegmentedControlChange(_ sender: UISegmentedControl) {
        switch OccurrenceTypes(rawValue: sender.selectedSegmentIndex)! {
        case .One:
            occurrenceType = "One"
        case .Daliy:
            occurrenceType = "Daliy"
        case .Weekly:
            occurrenceType = "Weekly"
        case .Monthly:
            occurrenceType = "Monthly"
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
    
    
    @IBAction func btnPressedAdd(_ sender: UIBarButtonItem) {
        print("chaveen")
        if validateUserInputs() {

            var calendarIdentifier = ""
            var addedToCalendar = false
            var eventDeleted = false
            let eventStore = EKEventStore()

            let expenseName = expenseNameTextField.text
            let amount = Double(amountTextField.text!)
            let endDate = datePicker.date
            let addToCalendarFlag = Bool(addToCalendarSwitch.isOn)
            let notes = notesTextView.text
            let occurrence = occurrenceType

            guard let appDelegate =
                    UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Expense", in: managedContext)!


           // var expense = NSManagedObject.init(entity: entity, insertInto: managedContext)
            var expense = NSManagedObject()

            if editingMode {
                expense = (editingExpense as? Expense)!
            } else {
                expense = NSManagedObject(entity: entity, insertInto: managedContext)
            }

            if addToCalendarFlag {
                if editingMode {
                    if let expense = editingExpense {
                        if !expense.addToCalendar {
                            if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                                eventStore.requestAccess(to: .event, completion: {
                                    granted, error in
                                    calendarIdentifier = self.createEvent(eventStore, title: expenseName!, eventDate: endDate, occurrence: "endDate")
                                })
                            } else {
                                calendarIdentifier = createEvent(eventStore, title: expenseName!, eventDate: endDate, occurrence: "endDate")
                            }
                        }
                    }
                } else {
                    if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                        eventStore.requestAccess(to: .event, completion: {
                            granted, error in
                            calendarIdentifier = self.createEvent(eventStore, title: expenseName!, eventDate: endDate, occurrence: "endDate")
                        })
                    } else {
                        calendarIdentifier = createEvent(eventStore, title: expenseName!, eventDate: endDate, occurrence: "endDate")
                    }
                }
                if calendarIdentifier != "" {
                    addedToCalendar = true
                }
            } else {
                if editingMode {
                    if let expense = editingExpense {
                        if expense.addToCalendar {
                            if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                                eventStore.requestAccess(to: .event, completion: { (granted, error) -> Void in
                                    eventDeleted = self.deleteEvent(eventStore, eventIdentifier: expense.calendarIdentifier!)
                                })
                            } else {
                                eventDeleted = deleteEvent(eventStore, eventIdentifier: expense.calendarIdentifier!)
                            }
                        }
                    }
                }
            }

            // Handle event creation state
            if eventDeleted {
                addedToCalendar = false
            }

            expense.setValue(expenseName, forKeyPath: "name")
            expense.setValue(amount, forKeyPath: "amount")
            expense.setValue(notes, forKeyPath: "notes")

            if editingMode {
                expense.setValue(editingExpense?.endDate, forKeyPath: "endDate")
            } else {
                expense.setValue(endDate, forKeyPath: "endDate")
            }

            expense.setValue(now, forKeyPath: "startDate")
            expense.setValue(addedToCalendar, forKeyPath: "addToCalendar")
            expense.setValue(occurrence, forKeyPath: "occurrence")
            expense.setValue(calendarIdentifier, forKey: "calendarIdentifier")

            selectedCategory?.addToExpense((expense as? Expense)!)

            do {

                try managedContext.save()
                expenses.append(expense)

            } catch _ as NSError {
                displayAlertView(alertTitle: "Error", alertDescription: "An error occured while saving the expense.")
            }

        } else {
            displayAlertView(alertTitle: "Error", alertDescription: "Please fill the required fields.")
        }

      dismissAddProjectPopOver()
        
    }
    
    // Creates an event in the EKEventStore
    func createEvent(_ eventStore: EKEventStore, title: String, eventDate: Date, occurrence: String) -> String {
        let event = EKEvent(eventStore: eventStore)
        var identifier = ""
        
        event.title = title
        event.startDate = eventDate
        event.endDate = eventDate.addingTimeInterval(3600 as TimeInterval)
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        let recurrenceRule =  EKRecurrenceRule.init(recurrenceWith: .monthly , interval: 1, end: EKRecurrenceEnd.init(end:eventDate.addingTimeInterval(3600 as TimeInterval)))
        
        event.recurrenceRules = [recurrenceRule]
        
        do {
            try eventStore.save(event, span: .thisEvent)
            identifier = event.eventIdentifier
        } catch {
            let alert = UIAlertController(title: "Error", message: "Calendar event could not be created!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        return identifier
    }
    
    // Removes an event from the EKEventStore
    func deleteEvent(_ eventStore: EKEventStore, eventIdentifier: String) -> Bool {
        var sucess = false
        let eventToRemove = eventStore.event(withIdentifier: eventIdentifier)
        if eventToRemove != nil {
            do {
                try eventStore.remove(eventToRemove!, span: .thisEvent)
                sucess = true
            } catch {
                let alert = UIAlertController(title: "Error", message: "Calendar event could not be deleted!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                sucess = false
            }
        }
        return sucess
    }
    
    // Handles the add button enable state
    func addButtonEnability() {
        if validateUserInputs() {
            addBtn.isEnabled = true;
        } else {
            addBtn.isEnabled = false;
        }
    }
    
    // Check if the required fields are empty or not
    func validateUserInputs() -> Bool {
        if !(expenseNameTextField.text?.isEmpty)! && !(amountTextField.text?.isEmpty)! && !(notesTextView.text == "") && !(notesTextView.text?.isEmpty)! {
            return true
        }
        return false
    }
    
    @IBAction func handleExpenseNameChange(_ sender: UITextField) {
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
extension AddExpensesViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            expenseNameTextField.becomeFirstResponder()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            amountTextField.becomeFirstResponder()
        }
        if indexPath.section == 0 && indexPath.row == 2 {
            dateLabel.becomeFirstResponder()
        }
        if indexPath.section == 0 && indexPath.row == 3 {
            datePicker.becomeFirstResponder()
        }
        if indexPath.section == 0 && indexPath.row == 4 {
            addToCalendarSwitch.becomeFirstResponder()
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            occurrenceSegmentedControl.becomeFirstResponder()
        }
        
        if indexPath.section == 1 && indexPath.row == 3 {
            notesTextView.becomeFirstResponder()
        }
        
     
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
}
