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

class AddExpensesViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate, UNUserNotificationCenterDelegate {
    
    
    var expenses: [NSManagedObject] = []
    let dateFormatter : Formatter = Formatter()
    var taskProgressPickerVisible = false
    var datePickerVisible = false
    var selectedCategory: Category?
    var editingMode: Bool = false
    var occurrenceType = ""
    let now = Date()
    let notificationCenter = UNUserNotificationCenter.current()
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
        // Configure User Notification Center
        notificationCenter.delegate = self
        
        if !editingMode {
            // Set start date to current
            datePicker.minimumDate = now
            dateLabel.text = formatter.formatDate(now)
            
            
            // Settings the placeholder for notes UITextView
            notesTextView.delegate = self
            notesTextView.text = NSLocalizedString("noteTextVIewPlaceHolder", comment: "")
            notesTextView.textColor = UIColor.lightGray
            
            occurrenceType = "One off"
        }
        
        amountTextField.keyboardType = .numberPad
        configureView()
        // Disable add button
        addButtonEnability()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newText = NSString(string: textField.text!).replacingCharacters(in: range, with: string)
        
        var totalAmountSpend : Double = 0.0
        let expenses = (selectedCategory!.expense!.allObjects as! [Expense])
        
        for index in expenses.indices {
            totalAmountSpend = totalAmountSpend + Double(expenses[index].amount)
        }
        
        let maxAmountAvailable = selectedCategory!.budget - totalAmountSpend
        
        if newText.isEmpty {
            return true
        }
        else if let doubleValue = Double(newText), doubleValue <= maxAmountAvailable {
            return true
        }
        return false
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
            self.navigationItem.title = NSLocalizedString("editExpenseHeaderTitle", comment: "")
            self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("editExpenseSaveButtonTitle", comment: "")
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
                                    calendarIdentifier = self.createEvent(eventStore, title: expenseName!, eventDate: endDate, occurrence: occurrence,amount: amount!,categoryName: (self.selectedCategory?.name)!)

                                })
                            } else {
                                calendarIdentifier = createEvent(eventStore, title: expenseName!, eventDate: endDate, occurrence: occurrence,amount: amount!,categoryName: (self.selectedCategory?.name)!)

                            }
                        }
                    }
                } else {
                    if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                        eventStore.requestAccess(to: .event, completion: {
                            granted, error in
                            calendarIdentifier = self.createEvent(eventStore, title: expenseName!, eventDate: endDate, occurrence: occurrence,amount: amount!,categoryName: (self.selectedCategory?.name)!)

                        })
                    } else {
                        calendarIdentifier = createEvent(eventStore, title: expenseName!, eventDate: endDate, occurrence: occurrence,amount: amount!,categoryName: (self.selectedCategory?.name)!)

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

            var totalAmountSpend : Double = 0.0
            var expenses = (selectedCategory!.expense!.allObjects as! [Expense])

            for index in expenses.indices {
                totalAmountSpend = totalAmountSpend + Double(expenses[index].amount)
            }
            var maxAmountAvailable = 0.0

            if editingMode {
                expense.setValue(editingExpense?.endDate, forKeyPath: "endDate")
                maxAmountAvailable = selectedCategory!.budget - (totalAmountSpend - amount!)
            } else {
                maxAmountAvailable = selectedCategory!.budget - totalAmountSpend
                expense.setValue(endDate, forKeyPath: "endDate")
            }

            expense.setValue(now, forKeyPath: "startDate")
            expense.setValue(addedToCalendar, forKeyPath: "addToCalendar")
            expense.setValue(occurrence, forKeyPath: "occurrence")
            expense.setValue(calendarIdentifier, forKey: "calendarIdentifier")

            if (Double((amountTextField.text)!)! <= maxAmountAvailable){
                selectedCategory?.addToExpense((expense as? Expense)!)

                do {
                    try managedContext.save()
                    expenses.append(expense as! Expense)

                } catch _ as NSError {
                    displayAlertView(alertTitle: Alerts.CommonAlert.TITLE, alertDescription: Alerts.CommonAlert.MESSAGE)
                }
                dismissAddProjectPopOver()
            } else {
                showToast(message: "Max Amount Available is \(maxAmountAvailable)", seconds: 0.9)
            }

        } else {
            displayAlertView(alertTitle: Alerts.InvalidParameters.TITLE, alertDescription: Alerts.InvalidParameters.MESSAGE)
        }
        
    }
    
    // Creates an event and notiifcation
    func createEvent(_ eventStore: EKEventStore, title: String, eventDate: Date, occurrence: String, amount: Double, categoryName: String) -> String {
        let event = EKEvent(eventStore: eventStore)
        var identifier = ""

        event.title = title
        event.startDate = eventDate
        event.endDate = eventDate.addingTimeInterval(3600 as TimeInterval)
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        let content = UNMutableNotificationContent()
        content.title = "Pending Payment"
        content.sound = .default
        content.body = "Your \(title) expense in category \(categoryName) due date is going to end soon. Please pay $ \(amount)"
        
        
        let targetDate = eventDate
        var trigger:UNCalendarNotificationTrigger?
        
        if (occurrence == "One"){
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                                                                      from: targetDate),repeats: false)
        } else if (occurrence == "Daliy"){
            let recurrenceRule =  EKRecurrenceRule.init(recurrenceWith: .daily, interval: 1, end: EKRecurrenceEnd.init(end:eventDate.addingTimeInterval(3600 as TimeInterval)))
            event.recurrenceRules = [recurrenceRule]
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute],
                                                                                                      from: targetDate),repeats: true)
        } else if (occurrence == "Weekly"){
            let recurrenceRule =  EKRecurrenceRule.init(recurrenceWith: .weekly, interval: 1, end: EKRecurrenceEnd.init(end:eventDate.addingTimeInterval(3600 as TimeInterval)))
            event.recurrenceRules = [recurrenceRule]
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.weekday ,.hour, .minute],
                                                                                                      from: targetDate),repeats: true)
        } else if (occurrence == "Monthly"){
            let recurrenceRule =  EKRecurrenceRule.init(recurrenceWith: .monthly, interval: 1, end: EKRecurrenceEnd.init(end:eventDate.addingTimeInterval(3600 as TimeInterval)))
            event.recurrenceRules = [recurrenceRule]
            trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.month, .weekday ,.hour, .minute],
                                                                                                      from: targetDate),repeats: true)
        }
        
        
        do {
            try eventStore.save(event, span: .thisEvent)
            identifier = event.eventIdentifier
        } catch {
            displayAlertView(alertTitle: Alerts.failedCalendarEvent.TITLE, alertDescription: Alerts.failedCalendarEvent.MESSAGE)
        }
        
        notificationCenter.getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }
    
                    let request = UNNotificationRequest(identifier: "\(UUID().uuidString)", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                        if error != nil {
                            print("something went wrong")
                        }
                    })
                    print("Scheduled Notifications")
                })
            case .authorized:
             let request = UNNotificationRequest(identifier: "\(UUID().uuidString)", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                    if error != nil {
                        print("something went wrong")
                    }
                })
                print("Scheduled Notifications")
            case .denied:
                print("Application Not Allowed to Display Notifications")
            case .provisional:
                print("Application Not Allowed to Display Notifications")
            case .ephemeral:
                print("Application Not Allowed to Display Notifications")
            }
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
                displayAlertView(alertTitle: Alerts.failedCalendarEvent.TITLE, alertDescription: Alerts.failedCalendarEvent.MESSAGE)
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
    
    func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            completionHandler(success)
        }
    }
    
    func validateAmount() -> Bool {
        var totalAmountSpend : Double = 0.0
        let expenses = (selectedCategory!.expense!.allObjects as! [Expense])
        
        for index in expenses.indices {
            totalAmountSpend = totalAmountSpend + Double(expenses[index].amount)
        }
        
        let maxAmountAvailable = selectedCategory!.budget - totalAmountSpend
        if (Double((amountTextField.text)!)! <= maxAmountAvailable){
            return true
        } else {
            showToast(message: "Max Amount Available is \(maxAmountAvailable)", seconds: 0.8)
            return false
        }
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
            textView.text = NSLocalizedString("noteTextVIewPlaceHolder", comment: "")
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
