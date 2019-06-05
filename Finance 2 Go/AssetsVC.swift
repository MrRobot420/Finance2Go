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
    var button_keys: [String?] = []
    var asset_keys: [String?] = []
    
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
        
        print("[*] Loading Assets...")
        let username = UserDefaults.standard.string(forKey: "logged_in_profile")
        assets = getAssetsFrom(name: username!)
        
        for asset in assets {
            if asset.assetname != nil {
                print("Asset: \(asset.assetname!)")
                scrollViewData.append(assetViewDataStruct.init(assetname: asset.assetname, profilename: asset.profilename, value: asset.value))
            }
        }
        
        fillScrollView(scroll_data: scrollViewData)
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
    
    // Fills the ScrollView with "life":
    func fillScrollView(scroll_data: [assetViewDataStruct]) {
        // How big the scroll view has to be in order to show all elements (and have place for them)
        let subViewHeight = 80
        let spacing = 20
        let subViewWidth = Int(self.scrollView.frame.width)
        scrollView.contentSize.height = CGFloat(subViewHeight + spacing) * CGFloat(scroll_data.count)
        scrollView.contentSize.width = self.scrollView.frame.width
        let label_length = 210
        let font_size: CGFloat! = 20
        let font_spacing: Int! = Int(CGFloat(subViewWidth / 2) - CGFloat(Double(label_length) / 3))
//        let font_spacing = 0
        
        
        var i = 0
        for data in scroll_data {
            print(data.value!)
            let view = AssetView(frame: CGRect(x: 0,
                                               y: ((subViewHeight + spacing) * i),
                                               width: subViewWidth,
                                               height: subViewHeight))
            view.backgroundColor = #colorLiteral(red: 0.3735761046, green: 0.7207441926, blue: 0.09675113112, alpha: 1)
            // CREATE new Label:
            let nameView = UILabel(frame: CGRect(x: 0 + label_length / 7, y: ((subViewHeight + spacing) * i) + 10, width: label_length, height: 30))
            nameView.text = " 🏦 \(data.assetname!)"
            nameView.textColor = UIColor.darkGray
            nameView.textAlignment = .center
            nameView.font = UIFont.boldSystemFont(ofSize: font_size)
            // CREATE new Label:
            let valueView = UILabel(frame: CGRect(x: font_spacing, y: ((subViewHeight + spacing) * i) + 40, width: label_length, height: 30))
            valueView.text = String(format: "%.2f € 💰" , data.value!)
//            valueView.text = String(format: "%.2f € 💰" , formatValue(value: data.value!))
            valueView.textColor = UIColor.white
            valueView.textAlignment = .right
            valueView.font = UIFont.boldSystemFont(ofSize: font_size)
            
            let deleteButton = UIButton(frame: CGRect(x: 0, y: ((subViewHeight + spacing) * i) + 40, width: label_length / 2 - 10, height: 30))
            deleteButton.tintColor = UIColor.black
            deleteButton.backgroundColor = UIColor.red
            deleteButton.setTitle("X", for: UIControl.State.normal)
            deleteButton.isEnabled = true
//            let font = UIFont.systemFont(ofSize: 20)
//            let attributes = [NSAttributedString.Key.font: font]
//            let attributeString = NSAttributedString(string: data.assetname!, attributes: attributes)
//            deleteButton.setAttributedTitle(attributeString, for: .normal)
//            deleteButton.state =
//            deleteButton.set
            deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
            button_keys.insert(deleteButton.description, at: i)
            asset_keys.insert(data.assetname, at: i)
            
            // Add the views:
            self.scrollView.addSubview(view)
            self.scrollView.addSubview(nameView)
            self.scrollView.addSubview(valueView)
            self.scrollView.addSubview(deleteButton)
            
            i += 1
        }
    }
    
    // Deletes a object
    @objc func deleteAction(_ sender: UIButton) {
        
        print("Delete-Button [\(sender.description)] was pressed!")
        var toDelete = ""
        
        for i in 0...button_keys.count-1 {
            if sender.description == button_keys[i] {
                print("Everything has been deleted!!!!! \n\n")
                toDelete = asset_keys[i]!
                break
            }
        }
        
        // Try deleting!
        if let result = try? context.fetch(fetchRequest) as! [Asset] {
            for object in result {
                if object.assetname == toDelete {
                    print("[X] Found Asset to delete!")
                    context.delete(object)
                    print("[X] DELETED: \(object.assetname!)")
                }
            }
        }
        
        do {
            try context.save()
            print("[√] Saved!")
        } catch {
            print("[X] Failed Saving!")
        }
        
    }
    
    
    func formatValue(value: Double!) -> String! {
        let result = String(value)
        
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.currencyCode = "USD"
//        formatter.currencySymbol = "€"
//        result = formatter.string(from: NSNumber(value: value))!
        
        return result
    }
    
    
    // FOR STATUS BAR "STATUS"
    override var prefersStatusBarHidden: Bool {
        return true
    }
}


// The VIEW for the assets:
class AssetView: UIView {
    
    // INIT:
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.addSubview(nameView)
//        self.addSubview(valueView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
