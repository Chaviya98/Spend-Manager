//
//  CustomCellExpenses.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-03-31.
//

import UIKit

protocol CustomCellExpensesDelegate {
    func viewNotes(cell:CustomCellExpenses, sender button: UIButton, data: String)
}
class CustomCellExpenses: UITableViewCell {
    
    var cellDelegate:CustomCellExpensesDelegate?
    var notes : String = "Not Found"
    
    let now: Date = Date()
    let colors:Colors = Colors()
    let formatter: Formatter = Formatter()
    let calculations : DateTimeCalculations = DateTimeCalculations()
    let reminderCalculations : ReminderCalculations = ReminderCalculations()
    
    @IBOutlet weak var lblExpensesNo: UILabel!
    @IBOutlet weak var lblExpensesName: UILabel!
    @IBOutlet weak var lblExpensesAmount: UILabel!
    @IBOutlet weak var lblDueDate: UILabel!
    @IBOutlet weak var lblDaysLeft: UILabel!
    @IBOutlet weak var budgetCircularProgressBar: CircularProgressBar!
    @IBOutlet weak var btnInfor: UIButton!
    @IBOutlet weak var daysRemainingLinearProgressBar: LinearProgressBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func handleViewNotesButtonClick(_ sender: UIButton) {
        self.cellDelegate?.viewNotes(cell: self, sender: sender as! UIButton, data: notes)
    }
    
    
    func commonInt(_ expensesNo:Int, expensesName:String, expensesAmount :Double, startDate:Date, dueDate:Date, notes:String , budget:Double){
        
        let (daysLeft, hoursLeft, minutesLeft) = calculations.getTimeDifference(now, end: dueDate)
        let remainingDaysPercentage = calculations.getRemainingTime(startDate, end: dueDate)
        let remainingBudgetPercentage = reminderCalculations.getRemainingBudget(budget, amount: expensesAmount)
        
        lblExpensesName.text = expensesName
        lblExpensesNo.text = String(expensesNo)
        lblExpensesAmount.text = String(expensesAmount)
        lblDueDate.text = "Due: \(formatter.formatDate(dueDate))"
        lblDaysLeft.text = "\(daysLeft) Days \(hoursLeft) Hours \(minutesLeft) Minutes Remaining"
        
        DispatchQueue.main.async {
            let colours = self.colors.getProgressGradient(remainingBudgetPercentage, negative: true)
            self.budgetCircularProgressBar.startGradientColor = colours[0]
            self.budgetCircularProgressBar.endGradientColor = colours[1]
            self.budgetCircularProgressBar.progress = CGFloat(remainingBudgetPercentage) / 100
        }

        DispatchQueue.main.async {
            let colours = self.colors.getProgressGradient(remainingDaysPercentage, negative: true)
            self.daysRemainingLinearProgressBar.startGradientColor = colours[0]
            self.daysRemainingLinearProgressBar.endGradientColor = colours[1]
            self.daysRemainingLinearProgressBar.progress = CGFloat(remainingDaysPercentage) / 100
        }
        
        self.notes = notes
    }
}
