//
//  ViewController.swift
//  Finance 2 Go
//
//  Created by Maximilian Karl on 16.05.19.
//  Copyright © 2019 RobotSystems. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var profileField: UITextField!
    
    
    @IBAction func goButton(_ sender: Any) {
        
    }
    
    @IBAction func addProfile(_ sender: Any) {
        //self.unwindForSegue("addProfileSegue", towardsViewController: CreateProfileVC)
    }
    
    @IBAction func settingsButton(_ sender: Any) {
        
    }
    
    // VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "money.jpg")!)
    }


}

