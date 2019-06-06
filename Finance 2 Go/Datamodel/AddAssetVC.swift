//
//  AddAssetVC.swift
//  Finance 2 Go
//
//  Created by Maximilian Karl on 02.06.19.
//  Copyright © 2019 RobotSystems. All rights reserved.
//


import Foundation
import CoreData
import KeychainSwift


struct AssetKeys {
    static let assetname = "assetname"
    static let profilename = "profilename"
    static let id = "id"
    static let value = "value"
    static let type = "type"
}

class AddAssetsVC: UIViewController, UITextFieldDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Asset")       // What to fetch
    
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    var profiles: [Profile] = []
    var assets: [Asset] = []
    var username: String! = ""
    var assetCount: Int! = 0
    
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var valueField: UITextField!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    //let addSegue = UIStoryboardSegue.
    
    @IBAction func addAsset(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Asset", in: context)!
        let asset = NSManagedObject(entity: entity, insertInto: context)
        assetCount = countList(list: assets)
        
        let state = checkInputs()
        
        if state {
            let name_value = nameField.text
            let type_value = typeField.text
            let value_value = Double(valueField.text!)!
            
            print("[+] Setting Values...")
            asset.setValue(name_value, forKey: AssetKeys.assetname)
            asset.setValue(assetCount+1, forKey: AssetKeys.id)
            asset.setValue(type_value, forKey: AssetKeys.type)
            asset.setValue(username, forKey: AssetKeys.profilename)
            asset.setValue(value_value, forKey: AssetKeys.value)
        } else {
            print("[X] Values were not set!")
        }
        
        do {
            if shouldPerformSegueWithIdentifier(identifier: "addAssetSegue", state: state, sender: nil) {
                try context.save()
                print("[√] Saved!")
                self.performSegue(withIdentifier: "addAssetSegue", sender: nil)
            }
        } catch {
            print("[X] Failed Saving!")
        }
    }
    
    // Check if inputs are valid:
    func checkInputs() -> Bool {
        let name = nameField.text
        let type = typeField.text
        let value = valueField.text
        
        if name!.isEmpty || name == " " {
            showInfo(info: "Name erforderlich!", color: globColor.errorColor)
            return false
        } else {
            let taken = checkIfTaken(name: name!)
            if taken {
                showInfo(info: "Name vergeben!", color: globColor.errorColor)
                return false
            }
            if type!.isEmpty || type == " " {
                showInfo(info: "Typ erforderlich!", color: globColor.errorColor)
                return false
            } else {
                if value!.isEmpty || value == " " {
                    showInfo(info: "Wert erforderlich!", color: globColor.errorColor)
                    return false
                } else if isValidValue(testStr: value!) {
                    showInfo(info: "Asset hinzufügen...", color: globColor.successColor)
                    return true
                } else {
                    return false
                }
            }
        }
    }
    
    // Check if name already taken:
    func checkIfTaken(name: String!) -> Bool {
        
        for asset in assets {
            if asset.assetname != nil {
                if name!.lowercased() == asset.assetname!.lowercased() {
                    return true
                }
            }
        }
        return false
    }
    
    // Check if should perform segue:
    func shouldPerformSegueWithIdentifier(identifier: String?, state: Bool, sender: AnyObject?) -> Bool {
        if let ident = identifier {
            if ident == "addAssetSegue" {
                if state != true {
                    return false
                }
            }
        }
        return true
    }
    
    
    // ## ## ## ## ##   STANDARD   ## ## ## ## ##
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        nameField.delegate = self
        typeField.delegate = self
        valueField.delegate = self
        configureTextFields()
        topView.backgroundColor = globColor.mainColor    // Set Colors
        addButton.backgroundColor = globColor.mainColor    // Set Colors
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "money.jpg")!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification , object: nil)
    }
    
    // VIEW WILL APPEAR:
    override func viewWillAppear(_ animated: Bool) {
        // LOAD PROFILES INTO (global) LIST:
        do {
            print("\n###########   ADD-ASSETS SCREEN:   ###########\n")
            assets = try context.fetch(fetchRequest) as! [Asset]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        assetCount = countList(list: assets)
        print("<\(assetCount!)> ASSETS ARE ALREADY EXISTING! (globally)\n")
        username = UserDefaults.standard.string(forKey: "logged_in_profile")
        assets = getAssetsFrom(name: username!)
        print("[->] Logged in User: \(username!)")
        
        //assets = getDummyData()
        
        print("[*] Loading all Assets...")
        for asset in assets {
            if asset.profilename != nil {
                print("\n##########   ASSET   ############")
                print("Name:\t\t \(asset.assetname!)")
                print("Profile:\t \(asset.profilename!)")
                print("ID:\t\t\t \(asset.id)")
                print(String(format: "Value:\t\t %.2f €", asset.value))
                print("#################################\n")
            }
        }
    }
    
    // Sets the PLACEHOLDER for the textfields
    func configureTextFields() {
        nameField.placeholder = "Name"
        typeField.placeholder = "Typ"
        valueField.placeholder = "Wert"
        valueField.keyboardType = UIKeyboardType.numberPad
    }
    
    // Get assets from profile:
    func getAssetsFrom(name: String) -> [Asset] {
        var corresponding_assets: [Asset] = []
        
        for asset in assets {
            if asset.profilename != nil {
                if asset.profilename == name {
                    corresponding_assets.append(asset)
                }
            }
        }
        return corresponding_assets
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
    
    // Counts the elements of the list
    func countList(list: [Asset]) -> Int {
        var counter: Int = 0
        for asset in list {
            if asset.assetname != nil {
                counter += 1
            }
        }
        return counter
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
        
        if editBlock == true {
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
            editBlock = false
        } else if typeField.isEditing == true {
            editBlock = true
        } else if valueField.isEditing == true {
            editBlock = true
        } else {
            editBlock = false
        }
        return editBlock
    }
    
    // VALIDATES AGE
    func isValidValue(testStr:String) -> Bool {
        let valueRegEx = "[0-9.\\.0-9]{1,19}"
        
        let valueTest = NSPredicate(format:"SELF MATCHES %@", valueRegEx)
        
        if valueTest.evaluate(with: testStr)  {
            if Double(testStr)! >= 0 {
                return true
            }
            showInfo(info: "Must be >= 0.00", color: globColor.errorColor)
            return false
        } else {
            showInfo(info: "Must be floating point number!", color: globColor.errorColor)
            return false
        }
        
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
                //infoLabel.text = "DELETED"
                print("[√] Deleted all assets!")
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
}
