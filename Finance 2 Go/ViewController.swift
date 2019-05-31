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
    let context = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Profile")
    
    
    @IBOutlet weak var infoLabel: UILabel!
    
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
    
    // Called when GO - Button is pressed!
    @IBAction func goButton(_ sender: Any) {
        let name_value = nameField.text
        let password_value = passwordField.text
        
        if shouldPerformSegueWithIdentifier(identifier: "OverviewSegue", sender: nil) {
            showInfo(info: "Korrekte Daten 😎", color: #colorLiteral(red: 0.3735761046, green: 0.7207441926, blue: 0.09675113112, alpha: 1))
            self.performSegue(withIdentifier: "OverviewSegue", sender: nil)
        } else if name_value!.isEmpty || name_value == " " {
            showInfo(info: "Name eingeben", color: #colorLiteral(red: 0.7207441926, green: 0.02335692724, blue: 0.06600695687, alpha: 1))
        } else if password_value!.isEmpty || password_value == " " {
            showInfo(info: "Passwort eingeben", color: #colorLiteral(red: 0.7207441926, green: 0.02335692724, blue: 0.06600695687, alpha: 1))
        } else {
            showInfo(info: "Falsche Daten!", color: #colorLiteral(red: 0.7207441926, green: 0.02335692724, blue: 0.06600695687, alpha: 1))
        }
    }
    
    // Check if segue should be called
    func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if checkIfValidPassword() {
            return true
        }
        return false
    }
    
    // PREPARES the segue:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OverviewSegue" {
            if let overviewVC = segue.destination as? OverviewVC {
                overviewVC.infoObject = nameField.text!
            }
        }
    }
    
    // Checks if the password is valid:         (In future with hashing!)
    func checkIfValidPassword() -> Bool {
        let currentName = nameField.text
        let currentPw = passwordField.text
        
        for profile in profiles {
            if profile.name != nil {
                if profile.name == currentName {
                    if profile.password == currentPw {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    // SHOW Info in selected color:
    func showInfo(info:String!, color: UIColor!) {
        if color == #colorLiteral(red: 0.3735761046, green: 0.7207441926, blue: 0.09675113112, alpha: 1) {
            print("[√] SUCCESS: \(info!) ")
            infoLabel.text = info
            infoLabel.textColor = color
        } else {
            print("[X] ERROR: \(info!) ")
            infoLabel.text = info
            infoLabel.textColor = color
        }
    }
    
    @IBAction func addProfile(_ sender: Any) {
        //self.unwindForSegue("addProfileSegue", towardsViewController: CreateProfileVC)
        //prepare(for: CreateProfileSegue, sender: ViewController)
    }
    
    // Show Info about existing Profiles
    @IBAction func profileInfos(_ sender: Any) {
        print("[i] Showing profile-info alert ℹ️: \n")
        print("###########   PROFILES:   ###########\n")
        var message = ""
        
        for profile in profiles {
            if profile.name != nil {
                message += "\(Int32(profile.id)) - \(profile.name!) \n"
                print("[ ID ]:\t\t\t \(Int32(profile.id))")
                print("[ NAME ]:\t\t \(profile.name!)")
                print("[ MAIL ]:\t\t \(profile.email!)")
                print("[ AGE ]:\t\t \(Int16(profile.age))")
                print("[ PASSWORD ]:\t \(profile.password!)")
                print("\n#####################################\n")
            }
        }
        
        let alert = UIAlertController(title: "Profile 👤", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "✅ VERSTANDEN 😎", style: .default, handler: nil))
        self.present(alert, animated: true)
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
        print("\n###########   LOGIN SCREEN:   ###########\n")
        var loggedIn = UserDefaults.standard.string(forKey: "logged_in_profile")
        
        if (loggedIn != nil) {
            UserDefaults.standard.removeObject(forKey: "logged_in_profile")
            print("[√] Logged out profile: \(loggedIn!)")
            loggedIn = ""
        }
        
    }
    
    // DO BEFORE View will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            //deleteAllData("Profile")
            profiles = try context.fetch(fetchRequest) as! [Profile]
            profiles = profiles.sorted(by: { $0.id < $1.id })
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
    
}

