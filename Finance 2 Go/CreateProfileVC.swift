//
//  CreateProfileVC.swift
//  Finance 2 Go
//
//  Created by Maximilian Karl on 16.05.19.
//  Copyright © 2019 RobotSystems. All rights reserved.
//

import UIKit
import CoreData
import KeychainSwift

struct Keys {
    static let name = "name"
    static let mail = "mail"
    static let age = "age"
    static let password = "password"
    static let keyPrefix = "finance_"
}

class CreateProfileVC: UIViewController, UITextFieldDelegate {
    
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var conf_passwordField: UITextField!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    
    // "Bestätigen" Button CREATES new profile
    @IBAction func createProfile(_ sender: Any) {
        // C O R E - D A T A    <CONTEXT>
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        //let profile = NSEntityDescription.entity(forEntityName: "Profile", in: context)
        
        //let name = NSManagedObject(entity: profile!, insertInto: context)
        //let email = NSManagedObject(entity: profile!, insertInto: context)
        //let age = NSManagedObject(entity: profile!, insertInto: context)
        //let password = NSManagedObject(entity: profile!, insertInto: context)
        
        let name_value = nameField.text
        let email_value = mailField.text
        let age_value = ageField.text
        let password_value = passwordField.text
        
        let state = checkInputs()
        
        if state {
            print("[+] Setting Values...")
            //name.setValue(name_value, forKey: "name")
            //email.setValue(email_value, forKey: "email")
            //age.setValue(age_value, forKey: "email")
            keychain.set(name_value!, forKey: Keys.name, withAccess: KeychainSwiftAccessOptions.accessibleAlways)
            keychain.set(email_value!, forKey: Keys.mail, withAccess: KeychainSwiftAccessOptions.accessibleAlways)
            keychain.set(age_value!, forKey: Keys.age, withAccess: KeychainSwiftAccessOptions.accessibleAlways)
            
            if keychain.set(password_value!, forKey: Keys.password, withAccess: KeychainSwiftAccessOptions.accessibleAlways) {  // -> KeychainSwift
                print("[+ ] Keychain Set!")
                infoLabel.text = "Keychain set!"
                infoLabel.textColor = UIColor.green
            }
            //password.setValue(password_value, forKey: "password")        -> CoreData
        } else {
            print("[X] Values were not set!")
        }
        
        do {
            if shouldPerformSegueWithIdentifier(identifier: "profileCreated", state: state, sender: nil) {
                try context.save()
                print("[√] Saved!")
                self.performSegue(withIdentifier: "profileCreated", sender: nil)
            }
        } catch {
            print("[X] Failed Saving!")
        }
    }
    
    // VALIDATES INPUTS
    func checkInputs() -> Bool {
        let name_value = nameField.text
        let email_value = mailField.text
        let age_value = ageField.text
        let password_value = passwordField.text
        
        // NAME:
        if name_value!.isEmpty || name_value == " " {
            print("[X] ERROR Name leer")
            infoLabel.text = "Name leer"
            infoLabel.textColor = UIColor.red
            return false
            // EMAIL:
        } else {
            if email_value!.isEmpty || email_value == " " {
                print("[X] ERROR E-Mail leer")
                infoLabel.text = "E-Mail leer"
                infoLabel.textColor = UIColor.red
                return false
            } else {
                if isValidEmail(testStr: email_value!) {
                    // AGE:
                    if age_value!.isEmpty || age_value == " " {
                        print("[X] ERROR Alter leer")
                        infoLabel.text = "Alter leer"
                        infoLabel.textColor = UIColor.red
                        return false
                    } else if isValidAge(testStr: age_value!) {
                        // PASSWORD:
                        if password_value!.isEmpty || password_value == " " {
                            print("[X] ERROR Passwort leer")
                            infoLabel.text = "Passwort leer"
                            infoLabel.textColor = UIColor.red
                            return false
                        } else if isValidPassword(testStr: password_value!) {
                            if password_value == conf_passwordField.text {
                                print("[√] Profil erstellt!")                   // <--- DESIRED OUTCOME!
                                infoLabel.text = "Profil erstellt!"
                                infoLabel.textColor = UIColor.green
                                return true
                            } else {
                                infoLabel.text = "untersch. Passwörter!"
                                infoLabel.textColor = UIColor.red
                                print("[X] ERROR Passwörter unterschiedlich!")
                                return false
                            }
                        } else {
                            infoLabel.text = "Ungültig: (8)"
                            infoLabel.textColor = UIColor.red
                            print("[X] ERROR Ungültiges Passwort: (8)!")
                            return false
                        }
                    } else {
                        return false
                    }
                } else {
                    infoLabel.text = "Email ungültig!"
                    infoLabel.textColor = UIColor.red
                    print("[X] ERROR Email ungültig!")
                    return false
                }
            }
        }
    }
    
    // VALIDATES EMAIL
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidAge(testStr:String) -> Bool {
        let ageRegEx = "[0-9]{1,3}"
        
        let ageTest = NSPredicate(format:"SELF MATCHES %@", ageRegEx)
        
        if ageTest.evaluate(with: testStr)  {
            if Int(testStr)! >= 14 {
                return true
            }
            print("[X] ERROR Must be >14")
            infoLabel.text = "Must be >14"
            infoLabel.textColor = UIColor.red
            return false
        } else {
            print("[X] ERROR Must be numeric")
            infoLabel.text = "Must be numeric"
            infoLabel.textColor = UIColor.red
            return false
        }
        
    }
    
    func isValidPassword(testStr:String) -> Bool {
        //    start-anchor  2 Uppercase let.  1 special ch.  2 digits        3 lowercase let.     end-anchor
        let passRegEx = "^(?=.*[A-Z].*[A-Z])(?=.*[!@#$&*])(?=.*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{8,64}$"
        
        let passTest = NSPredicate(format:"SELF MATCHES %@", passRegEx)
        return passTest.evaluate(with: testStr)
    }
    
    // Check if segue should be called
    func shouldPerformSegueWithIdentifier(identifier: String?, state: Bool, sender: AnyObject?) -> Bool {
        if let ident = identifier {
            if ident == "profileCreated" {
                if state != true {
                    return false
                }
            }
        }
        return true
    }
    
    // S T A N D A R D   V I E W   D I D   L O A D
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "money.jpg")!)
        nameField.delegate = self
        mailField.delegate = self
        ageField.delegate = self
        passwordField.delegate = self
        conf_passwordField.delegate = self
        configureTextFields()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification , object: nil)
    }
    
    func configureTextFields() {
        nameField.placeholder = "Name"
        mailField.placeholder = "E-Mail"
        ageField.placeholder = "Alter"
        passwordField.placeholder = "Passwort"
        conf_passwordField.placeholder = "Passwort bestätigen"
        ageField.keyboardType = UIKeyboardType.numberPad
    }
    
    // User touched the display:
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // OBJ-C Code for moving the frame up, while typing:
    @objc func keyboardWillChange(notification: Notification) {
        print("Keyboard will show: \(notification.name.rawValue)")      // Notification DEBUG
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let nameNoti = Notification.Name("UIKeyboardWillShowNotification")
        let nameNoti2 = Notification.Name("UIKeyboardWillChangeFrameNotification")
        
        let keyboardHeight: CGFloat
        keyboardHeight = keyboardRect.standardized.height - self.view.safeAreaInsets.bottom
        
        let editBlock = checkIfEditing()    // Check which field is edited
        
        if editBlock == false {
            if notification.name == nameNoti || notification.name == nameNoti2 {
                view.frame.origin.y = -keyboardHeight
            } else {
                view.frame.origin.y = 0
            }
        }
    }
    
    
    // Checks if there is critical editing done
    func checkIfEditing() -> Bool {
        var editBlock = false
        
        if nameField.isEditing == true {
            editBlock = true
        } else if mailField.isEditing == true {
            editBlock = true
        } else {
            editBlock = false
        }
        return editBlock
    }
    
    
    // DEINIT of notification.observer
    deinit {
        //Stop listening for keyboard hide/show events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}
