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
    
    
    @IBOutlet weak var lblExpensesNo: UILabel!
    @IBOutlet weak var lblExpensesName: UILabel!
    @IBOutlet weak var lblExpensesAmount: UILabel!
    @IBOutlet weak var lblDueDate: UILabel!
    @IBOutlet weak var lblDaysLeft: UILabel!
    @IBOutlet weak var budgetCircularProgressBar: UIView!
    @IBOutlet weak var btnInfor: UIButton!
    @IBOutlet weak var daysRemainingLinearProgressBar: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func commonInt(_ expensesNo:Int, expensesName:String, expensesAmount :Double, startDate:Date, dueDate:Date, notes:String){
        
        let (daysLeft, hoursLeft, minutesLeft) = calculations.getTimeDifference(now, end: dueDate)
        let remainingDaysPercentage = calculations.getRemainingTime(startDate, end: dueDate)
        
        lblExpensesName.text = expensesName
        lblExpensesNo.text = expensesNo
        lblDueDate.text = "Due: \(formatter.formatDate(dueDate))"
        lblDaysLeft.text = "\(daysLeft) Days \(hoursLeft) Hours \(minutesLeft) Minutes Remaining"
        
        DispatchQueue.main.async {
            let colours = self.colours.getProgressGradient(Int(taskProgress))
            self.taskProgressBar.startGradientColor = colours[0]
            self.taskProgressBar.endGradientColor = colours[1]
            self.taskProgressBar.progress = taskProgress / 100
        }
        
        DispatchQueue.main.async {
            let colours = self.colours.getProgressGradient(remainingDaysPercentage, negative: true)
            self.daysRemainingProgressBar.startGradientColor = colours[0]
            self.daysRemainingProgressBar.endGradientColor = colours[1]
            self.daysRemainingProgressBar.progress = CGFloat(remainingDaysPercentage) / 100
        }
        
        self.notes = notes
    }
}
