//
//  ViewController.swift
//  Finance 2 Go
//
//  Created by Maximilian Karl on 16.05.19.
//  Copyright © 2019 RobotSystems. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var profileField: UITextField!
    
    
    @IBAction func goButton(_ sender: Any) {
        //profileField
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OverviewSegue" {
            if let overviewVC = segue.destination as? OverviewVC {
                overviewVC.infoObject = profileField.text!
            }
        }
    }
    
    @IBAction func addProfile(_ sender: Any) {
        //self.unwindForSegue("addProfileSegue", towardsViewController: CreateProfileVC)
        //prepare(for: CreateProfileSegue, sender: ViewController)
    }
    
    @IBAction func settingsButton(_ sender: Any) {
        //prepare(for: SettingsSegue, sender: ViewController)
    }
    
    // VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "money.jpg")!)
        self.profileField.delegate = self
    }
    
    // User touched the display:
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

