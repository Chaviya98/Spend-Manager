//
//  CustomCellCategory.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-03-31.
//

import UIKit

protocol CustomCellCategoryDelegate {
    func customCell(cell : CustomCellCategory, sender button: UIButton, data : String)
}

class CustomCellCategory: UITableViewCell {
    
    var cellDelegate: CustomCellCategoryDelegate?
    var notes: String = "Not Found"
    let colors:Colors = Colors()
    
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var budgetValue: UILabel!
    @IBOutlet weak var cellContentView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func buttonPressedNotes(_ sender: Any) {
        self.cellDelegate?.customCell(cell: self,sender:sender as! UIButton,data:notes)
    }
    
    func commonInt(_ categoryName: String, budgetValue:Double, notes :String, color :String){
        self.categoryName.text = categoryName
        self.budgetValue.text = String(budgetValue)
        self.cellContentView.backgroundColor = colors.hexStringToUIColor(hex: color)
        self.notes = notes
    }
    
}
