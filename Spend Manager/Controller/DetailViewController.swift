//
//  DetailViewController.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-04-12.
//

import Foundation
import UIKit
import CoreData
import EventKit
import Charts

class DetailViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, ChartViewDelegate {

    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var totalBudgetLabel: UILabel!
    @IBOutlet weak var spendBudgetLabel: UILabel!
    @IBOutlet weak var remainingBudgetLabel: UILabel!
    
    @IBOutlet weak var addExpenseBtn: UIBarButtonItem!
    @IBOutlet weak var editExpenseBtn: UIBarButtonItem!
    
    @IBOutlet var expenseTable: UITableView!
    @IBOutlet weak var pieChartView: PieChartView!
    
    
    let formatter: Formatter = Formatter()
    let colours: Colors = Colors()
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    // let contex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let now = Date()
    
    var selectedCategory: Category? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the view
        pieChartView.delegate = self
    
     
        expenseTable.delegate = self
        expenseTable.dataSource = self
        configureView()
        
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        self.managedObjectContext = appDelegate.persistentContainer.viewContext
        
        // initializing the custom cell
        let nibName = UINib(nibName: "CustomCellExpenses", bundle: nil)
        expenseTable.register(nibName, forCellReuseIdentifier: "ExpenseCell")
        
        createPieChartDataSet()
        
    }
    
    private func createPieChartDataSet() {
        
        if let category = selectedCategory {
            pieChartView.centerText = selectedCategory?.name
            let expenses = (category.expense!.allObjects as! [Expense])
            
            var expensesNameArray : [String] = []
            var expensesAmountArray : [Double] = []
            var totalAmountSpend : Double = 0.0
            var otherAmount : Double = 0.0
            
            for index in expenses.indices {
                totalAmountSpend = totalAmountSpend + Double(expenses[index].amount)
            }
            
            let sortedExpenseArray = expenses.sorted(by: { $0.amount > $1.amount })
            
            for index in sortedExpenseArray.indices {
                if(index < 4){
                    expensesNameArray.append(sortedExpenseArray[index].name!)
                    expensesAmountArray.append(sortedExpenseArray[index].amount)
                } else {
                    otherAmount = otherAmount + sortedExpenseArray[index].amount
                }
            }
            
            if(sortedExpenseArray.count > 4){
                expensesNameArray.append("Others")
                expensesAmountArray.append(otherAmount)
            }
            expensesNameArray.append("Remaining")
            expensesAmountArray.append(category.budget - totalAmountSpend)
            
            
            if selectedCategory != nil && !expensesNameArray.isEmpty && !expensesAmountArray.isEmpty && !expenses.isEmpty {
                customizeChart(dataPoints: expensesNameArray, values: expensesAmountArray)
            }
        }
        
    }
 
    func configureView() {
        // Update the user interface for the detail item.
        if let category = selectedCategory {
            if let nameLabel = categoryNameLabel {
                nameLabel.text = category.name
            }
            if let totalBudgetLabel = totalBudgetLabel {
                totalBudgetLabel.text = String(category.budget)
            }
            
            let expenses = (category.expense!.allObjects as! [Expense])
            
            var totalAmountSpend : Double = 0.0
            
            for index in expenses.indices {
                totalAmountSpend = totalAmountSpend + Double(expenses[index].amount)
            }
            
            if let spendBudgetLabel = spendBudgetLabel {
                spendBudgetLabel.text = String(totalAmountSpend)
            }
            
            let remainingBudget = category.budget - totalAmountSpend
            
            if let remainingBudgetLabel = remainingBudgetLabel {
                remainingBudgetLabel.text = String(remainingBudget)
            }
            
        }

        if selectedCategory == nil {

       }
    }
    
    func customizeChart(dataPoints: [String], values: [Double]) {
        
        // 1. Set ChartDataEntry
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data:  dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        
        // 2. Set ChartDataSet
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: nil)
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
        
        // 3. Set ChartData
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        pieChartData.setValueFormatter(formatter)
        
       
        // 4. Assign it to the chart's data
        pieChartView.data = pieChartData
    }
    
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        var colors: [UIColor] = []
        for _ in 0..<numbersOfColor {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        return colors
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the default selected row
        let indexPath = IndexPath(row: 0, section: 0)
        if expenseTable.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath) {
            expenseTable.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        }
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let newExpense = Expense(context: context)
    
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addExpense" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AddExpensesViewController
            controller.selectedCategory = selectedCategory
            if let controller = segue.destination as? UIViewController {
                controller.popoverPresentationController!.delegate = self
                controller.preferredContentSize = CGSize(width: 320, height: 500)
            }
        }
        
        if segue.identifier == "showCategoryNotes" {
            let controller = segue.destination as! NotesPopoverController
            controller.notes = selectedCategory!.notes
            if let controller = segue.destination as? UIViewController {
                controller.popoverPresentationController!.delegate = self
                controller.preferredContentSize = CGSize(width: 300, height: 250)
            }
        }
        
        if segue.identifier == "editExpense" {
            if let indexPath = expenseTable.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! AddExpensesViewController
                controller.editingExpense = object as Expense
                controller.selectedCategory = selectedCategory
            }
        }
    }
    
    //    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        
        
        if selectedCategory == nil {
            addExpenseBtn.isEnabled = false
            editExpenseBtn.isEnabled = false
            expenseTable.setEmptyMessage(NSLocalizedString("hintMessageForExpenses", comment: ""), UIColor.black)
            return 0
        }
        
        if sectionInfo.numberOfObjects == 0 {
            editExpenseBtn.isEnabled = false
            expenseTable.setEmptyMessage(NSLocalizedString("emptyMessageForExpenses", comment: ""), UIColor.black)
        }
        
        return sectionInfo.numberOfObjects
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as! CustomCellExpenses
        
        let expense = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withExpense: expense, index: indexPath.row)
        cell.cellDelegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Expense> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        
        
        if selectedCategory != nil {
            // Setting a predicate
            let predicate = NSPredicate(format: "%K == %@", "category", selectedCategory as! Category)
            fetchRequest.predicate = predicate
        }
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Expense>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        expenseTable.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            expenseTable.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            expenseTable.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            expenseTable.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            expenseTable.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(expenseTable.cellForRow(at: indexPath!)! as! CustomCellExpenses, withExpense: anObject as! Expense, index: indexPath!.row)
        case .move:
            configureCell(expenseTable.cellForRow(at: indexPath!)! as! CustomCellExpenses, withExpense: anObject as! Expense, index: indexPath!.row)
            expenseTable.moveRow(at: indexPath!, to: newIndexPath!)
        }
        configureView()
    }
    
    func configureCell(_ cell: CustomCellExpenses, withExpense expense: Expense, index: Int) {
        cell.commonInt(index + 1, expensesName:expense.name!, expensesAmount :expense.amount, startDate:expense.startDate! as Date, dueDate:expense.endDate! as Date, notes:expense.notes!, budget:selectedCategory!.budget,occurrence: expense.occurrence!)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        expenseTable.reloadData()
        
    }
    
    func showPopoverFrom(cell: CustomCellExpenses, forButton button: UIButton, forNotes notes: String) {
        let buttonFrame = button.frame
        var showRect = cell.convert(buttonFrame, to: expenseTable)
        showRect = expenseTable.convert(showRect, to: view)
        showRect.origin.y -= 5
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NotesPopoverController") as? NotesPopoverController
        controller?.modalPresentationStyle = .popover
        controller?.preferredContentSize = CGSize(width: 300, height: 250)
        controller?.notes = notes
        
        if let popoverPresentationController = controller?.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = showRect
            
            if let popoverController = controller {
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
    
    
}


extension DetailViewController: CustomCellExpensesDelegate {
    func viewNotes(cell: CustomCellExpenses, sender button: UIButton, data: String) {
        self.showPopoverFrom(cell: cell, forButton: button, forNotes: data)
    }
}
