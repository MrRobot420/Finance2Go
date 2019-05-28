//
//  ViewController.swift
//  Finance 2 Go
//
//  Created by Maximilian Karl on 16.05.19.
//  Copyright © 2019 RobotSystems. All rights reserved.
//

import UIKit
import CoreData
import KeychainSwift

class ViewController: UIViewController, UITextFieldDelegate {
    
    var profiles: [Profile] = []
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //let entity = NSEntityDescription.entity(forEntityName: "Profile", in: context)
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nameField {
            print("Getting data from Keychain")
            nameField.text = keychain.get(Keys.name)
            passwordField.text = keychain.get(Keys.password)
            print(keychain.get(Keys.password)!)
            
            if keychain.lastResultCode != noErr {
                print(keychain.lastResultCode)
            }
        }
    }
    
    
    @IBAction func goButton(_ sender: Any) {
        //profileField
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OverviewSegue" {
            if let overviewVC = segue.destination as? OverviewVC {
                overviewVC.infoObject = nameField.text!
            }
        }
    }
    
    @IBAction func addProfile(_ sender: Any) {
        //self.unwindForSegue("addProfileSegue", towardsViewController: CreateProfileVC)
        //prepare(for: CreateProfileSegue, sender: ViewController)
    }
    
    @IBAction func settingsButton(_ sender: Any) {
        //prepare(for: SettingsSegue, sender: ViewController)
    }
    
    // VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "money.jpg")!)
        self.nameField.delegate = self
        self.passwordField.delegate = self
        configureTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Profile")
        
        //3
        do {
            //deleteAllData("Profile")
            profiles = try context.fetch(fetchRequest) as! [Profile]
            print("PROFILES: ")
            for profile in profiles {
                print("PROFILE - \(profile.name!):")
                print(profile.email!)
                print(Int16(profile.age))
                print(profile.password!)
                print("###########################")
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    
    // User touched the display:
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Sets PLACEHOLDER for text-fields:
    func configureTextFields() {
        nameField.placeholder = "Name"
        passwordField.placeholder = "Passwort"
    }
    
    // I NEED TO DELETE ALL DATA FIRST! (copied from net)
    func deleteAllData(_ entity:String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
}

