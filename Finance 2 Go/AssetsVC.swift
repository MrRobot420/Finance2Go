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
        setNeedsStatusBarAppearanceUpdate()
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
        
        // How big the scroll view has to be in order to show all elements (and have place for them)
        let subViewHeight = 80
        let spacing = 10
        let subViewWidth = Int(self.scrollView.frame.width)
        scrollView.contentSize.height = CGFloat(subViewHeight + spacing) * CGFloat(scrollViewData.count)
        scrollView.contentSize.width = self.scrollView.frame.width
        let label_length = 240
        let font_size: CGFloat! = 20
        let font_spacing: Int! = Int(CGFloat(subViewWidth / 2) - CGFloat(label_length / 2))
        

        var i = 0
        for data in scrollViewData {
            print(data.value!)
            let view = AssetView(frame: CGRect(x: 0,
                                               y: ((subViewHeight + spacing) * i),
                                               width: subViewWidth,
                                               height: subViewHeight))
//            view.frame = CGRect(x: 0, y: view.frame.height * CGFloat(i), width: self.scrollView.frame.width, height: CGFloat(80))
            view.backgroundColor = #colorLiteral(red: 0.3735761046, green: 0.7207441926, blue: 0.09675113112, alpha: 1)
//            view.nameView.text = data.assetname!
//            view.valueView.text = String(format: "Wert: %.2f €" , data.value!)
            
            let nameView = UILabel(frame: CGRect(x: font_spacing, y: ((subViewHeight + spacing) * i) + 10, width: label_length, height: 30))
            nameView.text = data.assetname!
            nameView.textColor = UIColor.white
            nameView.font = UIFont.boldSystemFont(ofSize: font_size)
            let valueView = UILabel(frame: CGRect(x: font_spacing, y: ((subViewHeight + spacing) * i) + 40, width: label_length, height: 30))
            valueView.text = String(format: "Wert: %.2f €" , data.value!)
            valueView.textColor = UIColor.white
            valueView.font = UIFont.boldSystemFont(ofSize: font_size)
            

            self.scrollView.addSubview(view)
            self.scrollView.addSubview(nameView)
            self.scrollView.addSubview(valueView)
            
            i += 1
        }
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
    
    
    // FOR STATUS BAR "STATUS"
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


// The VIEW for the assets:
class AssetView: UIView {
    
    let font_size: CGFloat! = 20
    
    // Name TextField
    var nameView : UILabel {
        let nameView = UILabel()
//        let nameView = UILabel(frame: CGRect(x: 30, y: 91, width: self.frame.width, height: 30))
        nameView.translatesAutoresizingMaskIntoConstraints = false
        nameView.textColor = UIColor.white
        nameView.font = UIFont.boldSystemFont(ofSize: font_size)
        //nameView.sizeToFit()
        nameView.adjustsFontSizeToFitWidth = true
        return nameView
    }
    
    // Value TextField
    var valueView : UILabel {
        let valueView = UILabel()
//        let valueView = UILabel(frame: CGRect(x: 30, y: 131, width: self.frame.width, height: 30))
        valueView.translatesAutoresizingMaskIntoConstraints = false
        valueView.textColor = UIColor.white
        valueView.font = UIFont.boldSystemFont(ofSize: font_size)
        //valueView.sizeToFit()
        return valueView
    }
    
    // INIT:
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(nameView)
//        nameView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//        nameView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
//        nameView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        nameView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        

        self.addSubview(valueView)
//        valueView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
//        valueView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
//        valueView.topAnchor.constraint(equalTo: nameView.bottomAnchor).isActive = true
//        valueView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
