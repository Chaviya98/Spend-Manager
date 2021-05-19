//
//  MasterViewController.swift
//  Spend Manager
//
//  Created by Chaveen Ellawela on 2021-04-12.
//

import Foundation
import CoreData
import UIKit

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var sortByLetters:Bool = false
    var sortByClick:Bool = false
    var lastClick: TimeInterval = 0.0
    var lastIndexPath: IndexPath? = nil
    
    @IBOutlet var categoryTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        
        // initializing the custom cell
        let nibName = UINib(nibName: "CustomCellCategory", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CategoryCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        // Set the default selected row
        autoSelectTableRow()
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext

        do {
            try context.save()
        } catch {
      
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
            
            let now: TimeInterval = Date().timeIntervalSince1970
                if (now - lastClick < 0.3) &&
                    (lastIndexPath?.row == indexPath.row ) {
                    
                    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    let entity = NSEntityDescription.entity(forEntityName: "Category", in: managedContext)
                            let request = NSFetchRequest<NSFetchRequestResult>()
                            request.entity = entity
                    let predicate = NSPredicate(format: "name = %@", object.name!)
                            request.predicate = predicate
                            do {
                                var results =
                                    try managedContext.fetch(request)
                                var objectUpdate :NSManagedObject? = nil
                                for result in results where (result as AnyObject).name == object.name {
                                    objectUpdate = result as! NSManagedObject
                                }
                                let newOftenSelectedCount = object.oftenSelectedCount + 1
                                objectUpdate?.setValue(newOftenSelectedCount, forKey: "oftenSelectedCount")
                                sortByClick = true
                                do {
                                    try managedContext.save()

                                }catch let error as NSError {

                                }
                            }
                            catch let error as NSError {

                            }
                    autoSelectTableRow()
                    categoryTable.reloadData()
                } else {
                    self.performSegue(withIdentifier: "showCategoryDetails", sender: object)
                }
            
                lastClick = now
                lastIndexPath = indexPath
            
        }
    }
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCategoryDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.selectedCategory = object as Category
            }
        }
        
        if segue.identifier == "addCategory" {
            if let controller = segue.destination as? UIViewController {
                controller.popoverPresentationController!.delegate = self
                controller.preferredContentSize = CGSize(width: 320, height: 450)
            }
        }
        
        if segue.identifier == "editCategory" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! AddCategoryViewController
                controller.editingCategory = object as Category
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CustomCellCategory
        let category = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withCategory: category)
        cell.cellDelegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        autoSelectTableRow()
    }
    
    func autoSelectTableRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        if tableView.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                self.performSegue(withIdentifier: "showCategoryDetails", sender: object)
            }
        } else {
            let empty = {}
            self.performSegue(withIdentifier: "showCategoryDetails", sender: empty)
        }
    }
    
    
    
    var fetchedResultsController: NSFetchedResultsController<Category> {
        if (_fetchedResultsController != nil && sortByLetters != true && sortByClick != true) {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20

        // Edit the sort key as appropriate.
        if (sortByLetters){
            sortByLetters = false
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
        } else {
            sortByClick = false
            let sortDescriptor = NSSortDescriptor(key: "oftenSelectedCount", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
        }


        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
  
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        // update UI
        autoSelectTableRow()
        
        return _fetchedResultsController!
    }
    
    @IBAction func btnPressedSort(_ sender: Any) {
        sortByLetters = true
        autoSelectTableRow()
        categoryTable.reloadData()
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Category>? = nil
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    func configureCell(_ cell: CustomCellCategory, withCategory category: Category) {
        cell.commonInt(category.name!,budgetValue:category.budget, notes: category.notes! ,color : category.color!)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)! as! CustomCellCategory, withCategory: anObject as! Category)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)! as! CustomCellCategory, withCategory: anObject as! Category)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
        
        // update UI
        autoSelectTableRow()
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    func showPopoverFrom(cell: CustomCellCategory, forButton button: UIButton, forNotes notes: String) {
        let buttonFrame = button.frame
        var showRect = cell.convert(buttonFrame, to: categoryTable)
        showRect = categoryTable.convert(showRect, to: view)
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


extension MasterViewController: CustomCellCategoryDelegate {
    func customCell(cell: CustomCellCategory, sender button: UIButton, data: String) {
        self.showPopoverFrom(cell: cell, forButton: button, forNotes: data)
    }
}


