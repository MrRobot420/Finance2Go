//
//  SettingsVC.swift
//  Finance 2 Go
//
//  Created by Maximilian Karl on 16.05.19.
//  Copyright © 2019 RobotSystems. All rights reserved.
//

import UIKit
import CoreData
import PCLBlurEffectAlert

class SettingsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var deleteInfo: UILabel!
    @IBOutlet weak var colorPicker: UIPickerView!
    
    var pickerData: [String?] = [String]()
    let deletionInformation = "ALL Profiles DELETED!"
    var selectedColor = ""
    
    // Deletes all profiles:
    func deleteAllData(_ sender: Any) {
        deleteData("Profile")
        //deleteData("Account") ...
    }
    
    // Shows ALERT for "2-factor auth"
    @IBAction func showAlert() {
        let message = "Dies löscht ALLE Profile ‼️"
        
        let alert = PCLBlurEffectAlert.Controller(title: "🔐 Passwort Kriterien:", message: message, effect: UIBlurEffect(style: .dark), style: .alert)
        let no_button = PCLBlurEffectAlert.Action(title: "NEIN ❌", style: .default, handler: nil)
        let yes_button = PCLBlurEffectAlert.Action(title: "Ja ✅", style: .default, handler: deleteAllData(_:))
        
        alert.addAction(no_button)
        alert.addAction(yes_button)
        alert.configure(cornerRadius: 0)
        alert.configure(messageColor: UIColor.white)
        alert.configure(titleColor: UIColor.white)
        alert.configure(overlayBackgroundColor: globColor.overlayColor)
        
        print("[i] Showing profile-deletion alert ❌")
        self.present(alert, animated: true)
    }
    
    // Takes Actions when the confirm-button was pressed:
    @IBAction func confirmSettings(_ sender: Any) {
        setGlobalColors(color: selectedColor)
        self.viewDidLoad()
    }
    
    
    // STANDARD
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        
        self.colorPicker.delegate = self
        self.colorPicker.dataSource = self
        pickerData = ["red", "orange", "yellow", "green", "light blue", "dark blue", "purple"]
        
        setUserInterface()
        print("\n###########   SETTINGS:   ###########\n")
        // Do any additional setup after loading the view.
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
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
    
    // Sets the userinterface:
    func setUserInterface() {
        // PRESELECT THE PICKER-VIEW:
        let currentDesignColor = UserDefaults.standard.string(forKey: "mainColor")
        for i in 0...pickerData.count-1 {
            if currentDesignColor == pickerData[i] {
                colorPicker.selectRow(i, inComponent: 0, animated: true)
            }
        }
        
        topView.backgroundColor = globColor.mainColor    // Set Colors
        okButton.backgroundColor = globColor.mainColor    // Set Colors
    }
    
    func setGlobalColors(color: String) {
        if color.lowercased() == "green" {
            globColor.mainColor = #colorLiteral(red: 0.3735761046, green: 0.7207441926, blue: 0.09675113112, alpha: 1)
            UserDefaults.standard.set(color, forKey: "mainColor")
        } else if color.lowercased() == "orange" {
            globColor.mainColor = #colorLiteral(red: 0.914617703, green: 0.6187350153, blue: 0.1710565974, alpha: 1)
            UserDefaults.standard.set(color, forKey: "mainColor")
        } else if color.lowercased() == "light blue" {
            globColor.mainColor = #colorLiteral(red: 0.3009182322, green: 0.8358695099, blue: 0.8002899455, alpha: 1)
            UserDefaults.standard.set(color, forKey: "mainColor")
        } else if color.lowercased() == "dark blue" {
            globColor.mainColor = #colorLiteral(red: 0.1921295051, green: 0.3386588719, blue: 1, alpha: 1)
            UserDefaults.standard.set(color, forKey: "mainColor")
        } else if color.lowercased() == "yellow" {
            globColor.mainColor = #colorLiteral(red: 0.914617703, green: 0.860400427, blue: 0.1053048009, alpha: 1)
            UserDefaults.standard.set(color, forKey: "mainColor")
        } else if color.lowercased() == "purple" {
            globColor.mainColor = #colorLiteral(red: 0.6207566624, green: 0.2043031161, blue: 0.6195764682, alpha: 1)
            UserDefaults.standard.set(color, forKey: "mainColor")
        } else if color.lowercased() == "red" {
            globColor.mainColor = #colorLiteral(red: 0.8239609772, green: 0.07829545355, blue: 0.1074117443, alpha: 1)
            UserDefaults.standard.set(color, forKey: "mainColor")
        }
    }
    
    func getColor(color: String) -> UIColor {
        if color.lowercased() == "green" {
            return #colorLiteral(red: 0.3735761046, green: 0.7207441926, blue: 0.09675113112, alpha: 1)
        } else if color.lowercased() == "orange" {
            return #colorLiteral(red: 0.914617703, green: 0.6187350153, blue: 0.1710565974, alpha: 1)
        } else if color.lowercased() == "light blue" {
            return #colorLiteral(red: 0.3009182322, green: 0.8358695099, blue: 0.8002899455, alpha: 1)
        } else if color.lowercased() == "dark blue" {
            return #colorLiteral(red: 0.1921295051, green: 0.3386588719, blue: 1, alpha: 1)
        } else if color.lowercased() == "yellow" {
            return #colorLiteral(red: 0.914617703, green: 0.860400427, blue: 0.1053048009, alpha: 1)
        } else if color.lowercased() == "purple" {
            return #colorLiteral(red: 0.6207566624, green: 0.2043031161, blue: 0.6195764682, alpha: 1)
        } else if color.lowercased() == "red" {
            return #colorLiteral(red: 0.8239609772, green: 0.07829545355, blue: 0.1074117443, alpha: 1)
        } else {
            return #colorLiteral(red: 0.9953997462, green: 0.9840615719, blue: 0.9846442899, alpha: 1)
        }
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Should set the color
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row]
        
        let matchingColor = getColor(color: titleData!)
        let myTitle = NSAttributedString(string: titleData!, attributes: [NSAttributedString.Key.foregroundColor: matchingColor])
        
        return myTitle
    }
    
    // Sets selected pickerItem
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        
        selectedColor = (pickerData[row])!
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .left) {
            print("[GESTURE] User-Gesture: Swipe Left")
            performSegue(withIdentifier: "Settings2ViewController", sender: nil)
        }
        
        if (sender.direction == .right) {
            print("[GESTURE] User-Gesture: Swipe Right")
        }
    }
    
    // FOR STATUS BAR "STATUS"
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
