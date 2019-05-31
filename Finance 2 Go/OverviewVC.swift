//
//  OverviewVC.swift
//  Finance 2 Go
//
//  Created by Maximilian Karl on 16.05.19.
//  Copyright © 2019 RobotSystems. All rights reserved.
//

import UIKit
import CoreData

class OverviewVC: UIViewController, UITextFieldDelegate {
    
    var infoObject:String?
    var profile: Profile!
    var profiles:[Profile] = []
    var profileAmount:Int!
    var assets:[Asset] = []
    var assetAmount:Int!
    var transactions:[Transaction] = []
    var transactionAmount:Int!
    var saldo:Double!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let profileFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Profile")                    // What to fetch
    let assetFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Asset")                        // What to fetch
    let transactionFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Transaction")            // What to fetch
    
    
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var saldoLabel: UILabel!
    @IBOutlet weak var transxLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        if infoObject == "" {
//            profileLabel.text = "DEBUG"
//        } else if infoObject != nil {
//
//        }
        
        do {
            print("\n###########   PROFILE OVERVIEW:   ###########\n")
            profiles = try context.fetch(profileFetchRequest) as! [Profile]
            if infoObject != nil {
                print("[LOG] Logged in \(infoObject!)")
                findProfile(name: infoObject!)
                UserDefaults.standard.set(profile.name!, forKey: "logged_in_profile")
            } else {
                let username = UserDefaults.standard.string(forKey: "logged_in_profile")
                findProfile(name: username!)
                print("[LOG] User already logged in: \(username!)")
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
        
        profileLabel.text = profile.name
        accountLabel.text = String(assetAmount)
        transxLabel.text = String(transactionAmount)
    }
    
    // Load before view appers:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // LOAD PROFILES INTO (global) LIST:
        do {
            print("\n###########   PROFILE OVERVIEW:   ###########\n")
            profiles = try context.fetch(profileFetchRequest) as! [Profile]
            if infoObject != nil {
                print("[LOG] Logged in \(infoObject!)")
                findProfile(name: infoObject!)
                UserDefaults.standard.set(profile.name!, forKey: "logged_in_profile")
            } else {
                let username = UserDefaults.standard.string(forKey: "logged_in_profile")
                findProfile(name: username!)
                print("[LOG] User already logged in: \(username!)")
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
    }
    
    @IBAction func accountBtn(_ sender: Any) {
        
    }
    
    @IBAction func saldoBtn(_ sender: Any) {
        
    }
    
    @IBAction func transxBtn(_ sender: Any) {
        
    }
    
    // Find selected profile:
    func findProfile(name: String) {
        for _profile in profiles {
            if _profile.name != nil {
                print("[TASK] CHECKING profile: \(_profile.name!)...")
                if _profile.name == name {
                    print("[√] FOUND profile: \(_profile.name!)")
                    profile = _profile
                }
            } else {
                
            }
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
                if asset.assetname == name {
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
    
}
