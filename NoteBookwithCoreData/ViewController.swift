//
//  ViewController.swift
//  NoteBookwithCoreData
//
//  Created by Alican Kurt on 10.08.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var notesTableView: UITableView!
    var titleArray = [String]()
    var uuidArray = [UUID]()
    var choosenNoteId: UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connection between viewController and tableView
        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        // Added a button (+)  on navigator
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addNewButtonClick))
        
        
        getData()
        
        
    }
    
    
    // viewWillAppear function is used to show new Data after adding new data
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    
    @objc func getData(){
        
        // Deleting arrays
        titleArray.removeAll(keepingCapacity: false)
        uuidArray.removeAll(keepingCapacity: false)
        
        // Connection Core database
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // For get Data from Core Database
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    
                    if let title = result.value(forKey: "title") as? String{
                        titleArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        uuidArray.append(id)
                    }
                    
                }
                
                // Update TableView
                self.notesTableView.reloadData()
            }
      
            
            
        }catch{
            
        }
        
        
    }
    
    
    @objc func addNewButtonClick(){
        choosenNoteId = nil
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uuidArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    
    // Did select row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenNoteId = uuidArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC"{
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.choosenNoteId = choosenNoteId
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
            let idString = uuidArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == uuidArray[indexPath.row]{
                                context.delete(result)
                                titleArray.remove(at: indexPath.row)
                                uuidArray.remove(at: indexPath.row)
                                notesTableView.reloadData()
                                do{
                                    try context.save()
                                }catch{
                                    print("deleting error")
                                }
                                // if "results" contain many result, it work one times because break make break for loop
                                break
                            }
                        }
                    }
                }
                
            }catch{
                
            }
            
        }
    }
    
    
    
    
}

