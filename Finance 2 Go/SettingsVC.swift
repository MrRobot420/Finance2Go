//
//  SettingsVC.swift
//  Finance 2 Go
//
//  Created by Maximilian Karl on 16.05.19.
//  Copyright © 2019 RobotSystems. All rights reserved.
//

import UIKit
import CoreData

class SettingsVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var deleteInfo: UILabel!
    let deletionInformation = "ALL Profiles DELETED!"
    
    // Deletes all profiles:
    func deleteAllData(_ sender: Any) {
        deleteData("Profile")
        //deleteData("Account") ...
    }
    
    // Shows ALERT for "2-factor auth"
    @IBAction func showAlert() {
        let message = "Dies löscht ALLE Profile ‼️"
        let alert = UIAlertController(title: "⚠️ Profile löschen?", message: message, preferredStyle: .alert)
        print("[i] Showing profile-deletion alert ❌")
        alert.addAction(UIAlertAction(title: "NEIN ❌", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ja ✅", style: .default, handler: deleteAllData(_:)))
        self.present(alert, animated: true)
    }
    
    // STANDARD
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n###########   SETTINGS:   ###########\n")
        // Do any additional setup after loading the view.
    }
    
    //TO DELETE ALL DATA! (copied from net)
    func deleteData(_ entity: String) {
        let context = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context.delete(objectData)
                deleteInfo.text = deletionInformation
                print("[√] Deleted all profiles!")
                do {
                    try context.save()
                    print("[√] Saved!")
                } catch {
                    print("[X] Failed Saving!")
                }
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
    
}
