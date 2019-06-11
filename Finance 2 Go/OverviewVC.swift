//
//  OverviewVC.swift
//  Finance 2 Go
//
//  Created by Maximilian Karl on 16.05.19.
//  Copyright © 2019 RobotSystems. All rights reserved.
//

import UIKit
import CoreData
import KeychainSwift
import PCLBlurEffectAlert

class OverviewVC: UIViewController, UITextFieldDelegate {
    
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    
    var infoObject:String?
    var profile: Profile!
    var profiles:[Profile] = []
    var profileAmount:Int!
    var assets:[Asset] = []
    var assetAmount:Int!
    var transactions:[Transaction] = []
    var transactionAmount:Int!
    var saldo:Double!
    var formattedSaldo:String!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let profileFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Profile")                    // What to fetch
    let assetFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Asset")                        // What to fetch
    let transactionFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Transaction")            // What to fetch
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var assetsButton: UIButton!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var saldoButton: UIButton!
    @IBOutlet weak var saldoLabel: UILabel!
    @IBOutlet weak var transxLabel: UILabel!
    @IBOutlet weak var transxButton: UIButton!
    @IBOutlet weak var timeshiftButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        topView.backgroundColor = globColor.mainColor    // Set Colors
        assetsButton.backgroundColor = globColor.mainColor    // Set Colors
        saldoButton.backgroundColor = globColor.mainColor    // Set Colors
        transxButton.backgroundColor = globColor.mainColor    // Set Colors
        timeshiftButton.backgroundColor = globColor.mainColor    // Set Colors
        
        // Do any additional setup after loading the view.
        do {
            print("\n###########   PROFILE OVERVIEW:   ###########\n")
            profiles = try context.fetch(profileFetchRequest) as! [Profile]
            if infoObject != nil {
                print("[LOG] Logged in \(infoObject!) 🔓")
                findProfile(name: infoObject!)
                UserDefaults.standard.set(profile.name!, forKey: "logged_in_profile")
            } else {
                let username = UserDefaults.standard.string(forKey: "logged_in_profile")
                findProfile(name: username!)
                print("[LOG] User already logged in: \(username!) 🔓")
            }
            
            assets = try context.fetch(assetFetchRequest) as! [Asset]
            transactions = try context.fetch(transactionFetchRequest) as! [Transaction]
            
            if profile != nil {
                assets = getAssetsFrom(name: profile.name!)
                transactions = getTransactionsFrom(name: profile.name!)
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        assetAmount = countList(list: assets)
        transactionAmount = countList(list: transactions)
        profileAmount = countList(list: profiles)
        
        saldo = calculateSaldo()
        formattedSaldo = formatMoney(value: saldo)
        
        profileLabel.text = profile.name! + " 👤"
        accountLabel.text = String(assetAmount)
        saldoLabel.text = formattedSaldo
        transxLabel.text = String(transactionAmount)
    }
    
    // Load before view appers:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Shows ALERT for "2-factor auth"
    @IBAction func showAlert() {
        let message = "Dies löscht das Profil ‼️"
        
        let alert = PCLBlurEffectAlert.Controller(title: "❌ Profil löschen?", message: message, effect: UIBlurEffect(style: .dark), style: .alert)
        let no_button = PCLBlurEffectAlert.Action(title: "NEIN ❌", style: .default, handler: nil)
//        let yes_button = PCLBlurEffectAlert.Action(title: "Ja ✅", style: .default, handler: deleteProfileData(_:) as? ((PCLBlurEffectAlert.Action?) -> Void))
        let yes_button = PCLBlurEffectAlert.Action(title: "Ja ✅", style: .default, handler: deleteProfileData(_:))
        
        alert.addAction(no_button)
        alert.addAction(yes_button)
        alert.configure(cornerRadius: 0)
        alert.configure(messageColor: UIColor.white)
        alert.configure(titleColor: UIColor.white)
        alert.configure(overlayBackgroundColor: globColor.overlayColor)
        
        print("[i] Showing profile-deletion alert ❌")
        self.present(alert, animated: true)
    }
    
    // Shows ALERT for "2-factor auth"
    @IBAction func showKeyAlert() {
        let message = "Nutze Keychain zum Login 🔓"
        
        let alert = PCLBlurEffectAlert.Controller(title: "🔐 Daten speichern?", message: message, effect: UIBlurEffect(style: .dark), style: .alert)
        let no_button = PCLBlurEffectAlert.Action(title: "NEIN ❌", style: .default, handler: nil)
//        let yes_button = PCLBlurEffectAlert.Action(title: "Ja ✅", style: .default, handler: saveDataInKeychain(_:) as? ((PCLBlurEffectAlert.Action?) -> Void))
        let yes_button = PCLBlurEffectAlert.Action(title: "Ja ✅", style: .default, handler: saveDataInKeychain(_:))
        
        alert.addAction(no_button)
        alert.addAction(yes_button)
        alert.configure(cornerRadius: 0)
        alert.configure(messageColor: UIColor.white)
        alert.configure(titleColor: UIColor.white)
        alert.configure(overlayBackgroundColor: globColor.overlayColor)
        
        print("[i] Showing keychain-save alert ❌")
        self.present(alert, animated: true)
    }
    
    // SAVES DATA to Keychain: (activates a user for keychain)
    func saveDataInKeychain(_ entity: Any) {
        keychain.set(profile.name!, forKey: Keys.name, withAccess: .accessibleAlways)
        
        if keychain.set(profile.password!, forKey: Keys.password, withAccess: .accessibleAlways) {  // -> KeychainSwift
            print("[+] Keychain Set!")
        }
    }
    
    @IBAction func accountBtn(_ sender: Any) {
        
    }
    
    @IBAction func saldoBtn(_ sender: Any) {
        
    }
    
    @IBAction func transxBtn(_ sender: Any) {
        
    }
    
    // Calculates the value of all assets:
    func calculateSaldo() -> Double? {
        var value = 0.00
        for asset in assets {
            if asset.assetname != nil {
                if asset.profilename == profile.name {
                    value += asset.value
                }
            }
        }
        
        return value
    }
    
    // Euro-Formatting:
    func formatMoney(value: Double!) -> String {
        let result: String! = String(format: "%.2f", value)
        var char_array = Array(result)
        var end_string = ""
        var num_counter = 0
        
        // Formatting:
        for i in stride(from: char_array.count-1, to: -1, by: -1) {
            if char_array[i] != "." {
                num_counter += 1
                if num_counter == 3 {
                    num_counter = 0
                    if i == 0 {
                        end_string = String(char_array[i]) + end_string
                    } else {
                        end_string = "." + String(char_array[i]) + end_string
                    }
                } else {
                    end_string = String(char_array[i]) + end_string
                }
            } else {
                end_string = "," + end_string
                num_counter = 0
            }
        }
        return end_string + " €"
    }
    
    // Find selected profile:
    func findProfile(name: String) {
        for _profile in profiles {
            if _profile.name != nil {
                print("[TASK] CHECKING profile: \(_profile.name!)...")
                if _profile.name == name {
                    print("[√] FOUND profile: \(_profile.name!)")
                    profile = _profile
                    break
                }
            } else {
                
            }
        }
    }
    
    // Deletes a profile and all asset / transaction - data:
    func deleteProfileData(_ entity: Any) {
        var deletedID = 0
        
        // Try deleting the ASSETS: (FIRST!! -> not available)
        if let result = try? context.fetch(assetFetchRequest) as? [Asset] {
            for object in result {
                if object.profilename == profile.name {
                    deletedID = Int(object.id)
                    context.delete(object)
                    print("[X] DELETED: \(object.assetname!)")
                }
            }
        }
        
        
        // Delete Profile
        for user in profiles {
            if user.name != nil {
                if user.name == profile.name {
                    print("[X] DELETED: \(user.name!)")
                    context.delete(user)
                    break
                }
            }
        }
        
        // Remove from list (NOT NECESSARY!)
        for i in 0...profiles.count-1 {
            if profiles[i].name != nil {
                if profiles[i].name == profile.name {
                    print("[x] REMOVED Profile from internal list")
                    profiles.remove(at: i)
                    break
                }
            }
        }
        
        do {
            try context.save()
            print("[√] Saved!")
        } catch {
            print("[X] Failed Saving!")
        }
        
        updateIDs(id: deletedID)
        performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    
    // Deletes OLD IDs and replaces them with new ones:
    func updateIDs(id: Int) {
        if let result = try? context.fetch(assetFetchRequest) as? [Asset] {
            for object in result {
                if object.id > id {
                    profile.setValue(Int(object.id) - 1, forKey: Keys.id)
                }
            }
        }
        
        do {
            try context.save()
            print("[√] Updated IDs!")
        } catch {
            print("Error while updating IDs!")
        }
    }
    
    // Counts the elements of the list
    func countList(list: [Profile]) -> Int {
        var counter = 0
        for profile in list {
            if profile.name != nil {
                counter += 1
            }
        }
        return counter
    }
    
    // Counts the elements of the list
    func countList(list: [Asset]) -> Int {
        var counter = 0
        for asset in list {
            if asset.assetname != nil {
                counter += 1
            }
        }
        return counter
    }
    
    // Counts the elements of the list
    func countList(list: [Transaction]) -> Int {
        var counter = 0
        for tx in list {
            if tx.assetname != nil {
                counter += 1
            }
        }
        return counter
    }
    
    // Get assets from profile:
    func getAssetsFrom(name: String) -> [Asset] {
        var corresponding_assets: [Asset] = []
        
        for asset in assets {
            if asset.assetname != nil {
                if asset.profilename == name {
                    corresponding_assets.append(asset)
                }
            }
        }
        return corresponding_assets
    }
    
    // Get transactions from profile:
    func getTransactionsFrom(name: String) -> [Transaction] {
        var corresponding_transactions: [Transaction] = []
        
        for transaction in transactions {
            if transaction.assetname != nil {
                if transaction.assetname == name {
                    corresponding_transactions.append(transaction)
                }
            }
        }
        return corresponding_transactions
    }
    
    // FOR STATUS BAR "STATUS"
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
