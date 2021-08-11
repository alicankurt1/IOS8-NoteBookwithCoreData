//
//  DetailsVC.swift
//  NoteBookwithCoreData
//
//  Created by Alican Kurt on 10.08.2021.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var infoText: UITextField!
    @IBOutlet weak var dateText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var choosenNoteId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if choosenNoteId != nil{
            
            // Hide Save Button
            saveButton.isHidden = true
            
            // Connection Core Database
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
            let idString = choosenNoteId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject]{
                        // try and import result
                        if let title = result.value(forKey: "title") as? String, let info = result.value(forKey: "info") as? String, let date = result.value(forKey: "date") as? String, let imageData = result.value(forKey: "image") as? Data{
                            titleText.text = title
                            infoText.text = info
                            dateText.text = date
                            photoImageView.image = UIImage(data: imageData)
                        }
                        
                        
                    }
                    
                
                    
                }
            }catch{
                print("Selected Error")
            }
            
        }else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            saveButton.backgroundColor = .lightGray
        }
        

        // For hide keyboard after writing
        let keyboardGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(keyboardGestureRecognizer)
        
        photoImageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        photoImageView.addGestureRecognizer(imageTapRecognizer)
        
        
    }
    
    //Selecting Image in Gallery
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        // You can edit photo's size
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    // After selecting image in Gallery
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        photoImageView.image = info[.originalImage] as? UIImage
        saveButton.backgroundColor = .blue
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // Hide Keyboard with Gesture Recognizer
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    

    
    @IBAction func saveClick(_ sender: Any) {
        
        // Connect Core Database and Insert new Note
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newNote = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
        
        // Attributes
        newNote.setValue(UUID(), forKey: "id")
        newNote.setValue(titleText.text!, forKey: "title")
        newNote.setValue(infoText.text!, forKey: "info")
        newNote.setValue(dateText.text!, forKey: "date")
        
        let imageData = photoImageView.image?.jpegData(compressionQuality: 0.5)
        newNote.setValue(imageData, forKey: "image")
        
        do{
            try context.save()
            print("Save Success")
        }catch{
            print("Save Error")
        }
        
        // Send Message to other page
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    
    
}
