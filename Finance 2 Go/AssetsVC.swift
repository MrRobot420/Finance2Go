//
//  AccountsVC.swift
//  Finance 2 Go
//
//  Created by Maximilian Karl on 31.05.19.
//  Copyright © 2019 RobotSystems. All rights reserved.
//

import Foundation
import CoreData
import KeychainSwift

class AssetsVC: UIViewController, UITextFieldDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Asset")       // What to fetch
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    var profiles: [Profile] = []
    
    // S T A N D A R D   V I E W   D I D   L O A D
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "money.jpg")!)
        
        //configureTextFields()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification , object: nil)
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
        
        //profileCount = countList(list: profiles)
        //print("<\(profileCount)> PROFILES ARE ALREADY EXISTING!\n")
        
    }
    
    
}
