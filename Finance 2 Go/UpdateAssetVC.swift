//
//  UpdateAssetVC.swift
//  Finance 2 Go
//
//  Created by Maximilian Karl on 18.06.19.
//  Copyright © 2019 RobotSystems. All rights reserved.
//

import UIKit
import Foundation
import CoreData


class UpdateAssetVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var valueField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Asset")       // What to fetch
    var assetname: String?
    var assets:[Asset] = []
    var change_asset: Asset!
    
    
    // Takes Care of the   U P D A T I N G :
    @IBAction func updateAsset(_ sender: Any) {
        
        if checkInputs() {
            if change_asset != nil {
                if nameField.text?.isEmpty == false {
                    change_asset.setValue(nameField.text, forKey: AssetKeys.assetname)
                }
                if typeField.text?.isEmpty == false {
                    change_asset.setValue(typeField.text, forKey: AssetKeys.type)
                }
                if valueField.text?.isEmpty == false {
                    change_asset.setValue(Double(valueField.text!)!, forKey: AssetKeys.value)
                }
            }
            do {
                try context.save()
                print("[√] Updated Asset \(nameField.text!)!")
            } catch {
                print("Error while updating IDs!")
            }
            performSegue(withIdentifier: "Update2AssetSegue", sender: nil)
        }
    }
    
    // Check if inputs are valid:
    func checkInputs() -> Bool {
        let name = nameField.text
        let type = typeField.text
        let value = valueField.text
        
        if name == " " {
            showInfo(info: "Name erforderlich!", color: globColor.errorColor)
            return false
        } else {
            let taken = checkIfTaken(name: name!)
            if taken {
                showInfo(info: "Name vergeben!", color: globColor.errorColor)
                return false
            }
            if type == " " {
                showInfo(info: "Typ erforderlich!", color: globColor.errorColor)
                return false
            } else {
                if value == " " {
                    showInfo(info: "Wert erforderlich!", color: globColor.errorColor)
                    return false
                } else if isValidValue(testStr: value!) {
                    showInfo(info: "Asset updaten...", color: globColor.successColor)
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
                if name!.lowercased() == change_asset.assetname {
                    return false
                }
                
                if name!.lowercased() == asset.assetname!.lowercased() {
                    return true
                }
            }
        }
        return false
    }
    
    // VALIDATES AGE
    func isValidValue(testStr:String) -> Bool {
        if valueField.text?.isEmpty == false {
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
        } else {
            return true
        }
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
    
    // ## ## ## ## ##   STANDARD   ## ## ## ## ##
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        assetname = UserDefaults.standard.string(forKey: "asset_to_update")      // Set asset to update
        
        do {
            print("\n###########   UPDATE ASSET SCREEN:   ###########\n")
            assets = try context.fetch(fetchRequest) as! [Asset]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for asset in assets {
            if asset.assetname != nil {
                if asset.assetname == assetname {
                    change_asset = asset
                }
            }
        }
        
        nameField.delegate = self
        typeField.delegate = self
        valueField.delegate = self
        configureTextFields()
        topView.backgroundColor = globColor.mainColor    // Set Colors
        updateButton.backgroundColor = globColor.mainColor    // Set Colors
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "money.jpg")!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification , object: nil)
        
        // IMPORTANT (GESTURE RECOGNITION)
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    
    // Sets the PLACEHOLDER for the textfields
    func configureTextFields() {
        nameField.placeholder = "Name"
        typeField.placeholder = "Typ"
        valueField.placeholder = "Wert"
        valueField.keyboardType = UIKeyboardType.numberPad
    }
    
    
    // Handles swipes:
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .left) {
            print("[GESTURE] User-Gesture: Swipe Left")
        }
        
        if (sender.direction == .right) {
            print("[GESTURE] User-Gesture: Swipe Right")
            performSegue(withIdentifier: "Update2AssetSegue", sender: nil)
        }
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
    
    // FOR STATUS BAR "STATUS"
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
