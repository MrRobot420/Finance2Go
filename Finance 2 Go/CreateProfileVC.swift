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
    static let id = "id"
    static let mail = "email"
    static let age = "age"
    static let password = "password"
    static let keyPrefix = "finance_"
}

// Screen width.
public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}


class CreateProfileVC: UIViewController, UITextFieldDelegate {
    
    // Shortcuts:   cmd + ctr + space = emojis
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Profile")       // What to fetch
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    var profiles: [Profile] = []
    var profileCount: Int32 = 0
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var conf_passwordField: UITextField!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    // Shows ALERT to password guidelines / criteria (alert)
    @IBAction func passwordInfo(_ sender: Any) {
        let message = "8 Zeichen\n2 Großbuchstaben\n3 Buchstaben\n2 Zahlen\n1 Sonderzeichen"
        let alert = UIAlertController(title: "🔐 Passwort Kriterien:", message: message, preferredStyle: .alert)
        print("[i] Showing password-info alert 🔐:")
        alert.addAction(UIAlertAction(title: "✅ VERSTANDEN 😎", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    
    // "Bestätigen" Button CREATES new profile
    @IBAction func createProfile(_ sender: Any) {
        // C O R E - D A T A    <CONTEXT>
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Profile", in: context)!
        let profile = NSManagedObject(entity: entity, insertInto: context)
        //let profile = NSEntityDescription.insertNewObject(forEntityName: "Profile", into: context) as! Profile
        
        
        let state = checkInputs()
        
        if state {
            let name_value = nameField.text
            let email_value = mailField.text
            let age_value = Int16(ageField.text!)!
            let password_value = passwordField.text
            
            print("[+] Setting Values...")
            profile.setValue(name_value, forKey: Keys.name)
            profile.setValue(profileCount+1, forKey: Keys.id)
            profile.setValue(email_value, forKey: Keys.mail)
            profile.setValue(age_value, forKey: Keys.age)
            profile.setValue(password_value, forKey: Keys.password)
            keychain.set(name_value!, forKey: Keys.name, withAccess: .accessibleAlways)
            
            if keychain.set(password_value!, forKey: Keys.password, withAccess: .accessibleAlways) {  // -> KeychainSwift
                print("[+] Keychain Set!")
                infoLabel.text = "Keychain set!"
                infoLabel.textColor = globColor.successColor
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
    
    // VALIDATES INPUTS
    func checkInputs() -> Bool {
        let name_value = nameField.text
        let email_value = mailField.text
        let age_value = ageField.text
        let password_value = passwordField.text
        
        
        // NAME:
        if name_value!.isEmpty || name_value == " " {
            showInfo(info: "Name leer", color: globColor.errorColor)
            return false
        } else {
            let taken = checkIfTaken(name: name_value!)
            if taken {
                showInfo(info: "Name vergeben!", color: globColor.errorColor)
                return false
            }
            
            // EMAIL:
            if email_value!.isEmpty || email_value == " " {
                showInfo(info: "E-Mail leer", color: globColor.errorColor)
                return false
            } else {
                if isValidEmail(testStr: email_value!) {
                    
                    // AGE:
                    if age_value!.isEmpty || age_value == " " {
                        showInfo(info: "Alter leer", color: globColor.errorColor)
                        return false
                    } else if isValidAge(testStr: age_value!) {
                        
                        // PASSWORD:
                        if password_value!.isEmpty || password_value == " " {
                            showInfo(info: "Passwort leer", color: globColor.errorColor)
                            return false
                        } else if isValidPassword(testStr: password_value!) {
                            if password_value == conf_passwordField.text {
                                
                                // LAST CHECK PASSED:
                                showInfo(info: "Profil erstellt", color: globColor.successColor)                // <--- DESIRED OUTCOME!
                                return true
                            } else {
                                showInfo(info: "untersch. Passwörter!", color: globColor.errorColor)
                                return false
                            }
                        } else {
                            showInfo(info: "Ungültig: (8)", color: globColor.errorColor)
                            return false
                        }
                    } else {
                        return false
                    }
                } else {
                    showInfo(info: "E-Mail ungültig!", color: globColor.errorColor)
                    return false
                }
            }
        }
    }
    
    // Check if name already taken:
    func checkIfTaken(name: String!) -> Bool {
        
        for profile in profiles {
            if profile.name != nil {
                if name!.lowercased() == profile.name!.lowercased() {
                    return true
                }
            }
        }
        return false
    }
    
    // VALIDATES EMAIL
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    // VALIDATES AGE
    func isValidAge(testStr:String) -> Bool {
        let ageRegEx = "[0-9]{1,3}"
        
        let ageTest = NSPredicate(format:"SELF MATCHES %@", ageRegEx)
        
        if ageTest.evaluate(with: testStr)  {
            if Int(testStr)! >= 14 {
                return true
            }
            showInfo(info: "Must be >14", color: #colorLiteral(red: 0.7207441926, green: 0.02335692724, blue: 0.06600695687, alpha: 1))
            return false
        } else {
            showInfo(info: "Must be numeric", color: #colorLiteral(red: 0.7207441926, green: 0.02335692724, blue: 0.06600695687, alpha: 1))
            return false
        }
        
    }
    
    // VALIDATES PASSWORD
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
        setNeedsStatusBarAppearanceUpdate()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "money.jpg")!)
        topView.backgroundColor = globColor.mainColor    // Set Colors
        okButton.backgroundColor = globColor.mainColor    // Set Colors
        
        nameField.delegate = self
        mailField.delegate = self
        ageField.delegate = self
        passwordField.delegate = self
        conf_passwordField.delegate = self
        configureTextFields()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification , object: nil)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    
    // Load before view appers:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // LOAD PROFILES INTO (global) LIST:
        do {
            print("\n###########   CREATE PROFILE:   ###########\n")
            profiles = try context.fetch(fetchRequest) as! [Profile]
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        profileCount = countList(list: profiles)
        print("<\(profileCount)> PROFILES ARE ALREADY EXISTING!\n")
        
    }
    
    // Counts the elements of the list
    func countList(list: [Profile]) -> Int32 {
        var counter: Int32 = 0
        for profile in list {
            if profile.name != nil {
                counter += 1
            }
        }
        return counter
    }
    
    // Sets the PLACEHOLDER for the textfields
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
        // FOR   D E B U G :
        //print("Keyboard will show: \(notification.name.rawValue)")      // Notification DEBUG
        
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
    
    // FOR STATUS BAR "STATUS"
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Handles Swipes:
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .left) {
            print("[GESTURE] User-Gesture: Swipe Left")
            performSegue(withIdentifier: "profileCreated", sender: nil)
        }
        
        if (sender.direction == .right) {
            print("[GESTURE] User-Gesture: Swipe Right")
        }
    }
}
