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

struct globColor {
    static var mainColor = #colorLiteral(red: 0.3735761046, green: 0.7207441926, blue: 0.09675113112, alpha: 1)              // ORIGINAL!
    static var secondaryColor = #colorLiteral(red: 0.3330089152, green: 0.333286792, blue: 0.3330519199, alpha: 1)         // Dark
    static var errorColor = #colorLiteral(red: 0.7207441926, green: 0.02335692724, blue: 0.06600695687, alpha: 1)
    static var successColor = #colorLiteral(red: 0.3735761046, green: 0.7207441926, blue: 0.09675113112, alpha: 1)
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    var profiles: [Profile] = []
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    let context = (UIApplication.shared.delegate as? AppDelegate)!.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Profile")
    
    @IBOutlet weak var topView: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
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
    
    // Set the default color for the design (and save it):
    func setGlobalColors(color: String) {
        if color.lowercased() == "green" {
            globColor.mainColor = #colorLiteral(red: 0.3735761046, green: 0.7207441926, blue: 0.09675113112, alpha: 1)
            UserDefaults.standard.set(color, forKey: "mainColor")
        } else if color.lowercased() == "orange" {
            globColor.mainColor = #colorLiteral(red: 0.914617703, green: 0.6187350153, blue: 0.1710565974, alpha: 1)
            UserDefaults.standard.set(color, forKey: "mainColor")
        } else if color.lowercased() == "light blue" {
            globColor.mainColor = #colorLiteral(red: 0.3388600137, green: 0.8456007261, blue: 1, alpha: 1)
            UserDefaults.standard.set(color, forKey: "mainColor")
        } else if color.lowercased() == "dark blue" {
            globColor.mainColor = #colorLiteral(red: 0.2832911622, green: 0.5227466498, blue: 1, alpha: 1)
            UserDefaults.standard.set(color, forKey: "mainColor")
        } else if color.lowercased() == "yellow" {
            globColor.mainColor = #colorLiteral(red: 0.914617703, green: 0.860400427, blue: 0.1053048009, alpha: 1)
            UserDefaults.standard.set(color, forKey: "mainColor")
        } else if color.lowercased() == "purple" {
            globColor.mainColor = #colorLiteral(red: 0.6207566624, green: 0.2043031161, blue: 0.6195764682, alpha: 1)
            UserDefaults.standard.set(color, forKey: "mainColor")
        } else if color.lowercased() == "red" {
            globColor.mainColor = #colorLiteral(red: 0.9249484455, green: 0.0898930601, blue: 0.1245416363, alpha: 1)
            UserDefaults.standard.set(color, forKey: "mainColor")
        }
    }
    
    // Called when GO - Button is pressed!
    @IBAction func goButton(_ sender: Any) {
        let name_value = nameField.text
        let password_value = passwordField.text
        
        if shouldPerformSegueWithIdentifier(identifier: "OverviewSegue", sender: nil) {
            showInfo(info: "Korrekte Daten 😎", color: globColor.successColor)
            self.performSegue(withIdentifier: "OverviewSegue", sender: nil)
        } else if name_value!.isEmpty || name_value == " " {
            showInfo(info: "Name eingeben", color: globColor.errorColor)
        } else if password_value!.isEmpty || password_value == " " {
            showInfo(info: "Passwort eingeben", color: globColor.errorColor)
        } else {
            showInfo(info: "Falsche Daten!", color: globColor.errorColor)
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
        if color == globColor.successColor {
            print("[√] SUCCESS: \(info!) ")
            infoLabel.text = info
            infoLabel.textColor = color
        } else {
            print("[X] ERROR: \(info!) ")
            infoLabel.text = info
            infoLabel.textColor = color
        }
    }
    
    // ADDs a profile:
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
    
    // For transitioning?
    @IBAction func settingsButton(_ sender: Any) {}
    
    // VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        self.nameField.delegate = self
        self.passwordField.delegate = self
        configureUserInterface()
        print("\n###########   LOGIN SCREEN:   ###########\n")
        var loggedIn = UserDefaults.standard.string(forKey: "logged_in_profile")
        
        if (loggedIn != nil) {
            UserDefaults.standard.removeObject(forKey: "logged_in_profile")
            print("[√] Logged out profile: \(loggedIn!) 🔒")
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
    func configureUserInterface() {
        let currentColor = UserDefaults.standard.string(forKey: "mainColor")
        if currentColor != nil { setGlobalColors(color: currentColor!) } else { setGlobalColors(color: "green") }
        nameField.placeholder = "Name"
        passwordField.placeholder = "Passwort"
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "money.jpg")!)
        topView.backgroundColor = globColor.mainColor    // Set Colors
        goButton.backgroundColor = globColor.mainColor    // Set Colors
        addButton.backgroundColor = globColor.mainColor    // Set Colors
    }
    
    // FOR STATUS BAR "STATUS"
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

