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

struct assetViewDataStruct {
    let assetname: String?
    let profilename: String?
    let value: Double?
    
}

class AssetsVC: UIViewController, UITextFieldDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Asset")       // What to fetch
    
    
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    var profiles: [Profile] = []
    var assets: [Asset] = []
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var scrollViewData = [assetViewDataStruct]()
    
    
    // S T A N D A R D   V I E W   D I D   L O A D
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "money.jpg")!)
        
        do {
            print("\n###########   ASSETS SCREEN:   ###########\n")
            assets = try context.fetch(fetchRequest) as! [Asset]
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        //configureTextFields()
        let username = UserDefaults.standard.string(forKey: "logged_in_profile")
        assets = getAssetsFrom(name: username!)
        
        //assets = getDummyData()
        
        print("[*] Loading Assets...")
        for asset in assets {
            if asset.assetname != nil {
                print("Asset: \(asset.assetname!)")
                scrollViewData.append(assetViewDataStruct.init(assetname: asset.assetname, profilename: asset.profilename, value: asset.value))
            }
        }
        
//        // How big the scroll view has to be in order to show all elements (and have place for them)
//        scrollView.contentSize.height = self.scrollView.frame.height * CGFloat(scrollViewData.count)
//
//        var i = 0
//        for data in scrollViewData {
//            let view = AssetView(frame: CGRect(x: self.scrollView.frame.width,
//                                               y: 50 * CGFloat(i) + 10,
//                                               width: self.scrollView.frame.width,
//                                               height: self.scrollView.frame.height - 20))
//            self.scrollView.addSubview(view)
//
//            i += 1
//        }
    }
    
    func getDummyData() {
        let entity = NSEntityDescription.entity(forEntityName: "Asset", in: context)!
        let asset = NSManagedObject(entity: entity, insertInto: context)
        
        asset.setValue("Sparda Konto", forKey: "assetname")
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
}


class AssetView: UIView {
    
    var nameView : UITextView {
        let nameView = UITextView()
        nameView.translatesAutoresizingMaskIntoConstraints = false
        nameView.backgroundColor = UIColor.darkGray
        return nameView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(nameView)
        nameView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        nameView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        nameView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        nameView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
