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
    let type: String?
}

class AssetsVC: UIViewController, UITextFieldDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Asset")       // What to fetch
    
    
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    var profiles: [Profile] = []
    var assets: [Asset] = []
    var button_keys: [String?] = []
    var asset_keys: [String?] = []
    var tapped_button: String! = ""
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var scrollViewData = [assetViewDataStruct]()
    @IBOutlet weak var topView: UIView!
    
    
    // S T A N D A R D   V I E W   D I D   L O A D
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "money.jpg")!)
        
        topView.backgroundColor = globColor.mainColor    // Set Colors
        
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
                scrollViewData.append(assetViewDataStruct.init(assetname: asset.assetname, profilename: asset.profilename, value: asset.value, type: asset.type))
            }
        }
        fillScrollView(scroll_data: scrollViewData)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .left) {
            print("[GESTURE] User-Gesture: Swipe Left")
        }
        
        if (sender.direction == .right) {
            print("[GESTURE] User-Gesture: Swipe Right")
            performSegue(withIdentifier: "Acc2OverviewSegue", sender: nil)
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
        
        
        var i = 0
        for data in scroll_data {
            print(data.value!)
            let view = AssetView(frame: CGRect(x: 0,
                                               y: ((subViewHeight + spacing) * i),
                                               width: subViewWidth,
                                               height: subViewHeight))
//            view.backgroundColor = #colorLiteral(red: 0.3735761046, green: 0.7207441926, blue: 0.09675113112, alpha: 1)
            view.backgroundColor = globColor.mainColor
            // CREATE new Label ASSETNAME:
            let nameView = UILabel(frame: CGRect(x: 0, y: ((subViewHeight + spacing) * i) + 10, width: label_length, height: 30))
            nameView.text = " 🏦 \(data.assetname!)"
            nameView.textColor = UIColor.darkGray
            nameView.textAlignment = .left
            nameView.font = UIFont.boldSystemFont(ofSize: 16)
            
            // CREATE new Label TYPE:
            let typeView = UILabel(frame: CGRect(x: label_length / 2 + 33, y: ((subViewHeight + spacing) * i) + 10, width: 150, height: 30))
            typeView.text = "\(data.type!) 💎"
            typeView.font = UIFont.boldSystemFont(ofSize: 12)
            typeView.textColor = #colorLiteral(red: 0.9967552883, green: 0.9521791773, blue: 1, alpha: 1)
            typeView.textAlignment = .right
            
            // CREATE new Label VALUE:
            let valueView = UILabel(frame: CGRect(x: font_spacing, y: ((subViewHeight + spacing) * i) + 40, width: label_length, height: 30))
            valueView.text = String(formatMoney(value: data.value!) + " 💰")
            valueView.textColor = #colorLiteral(red: 0.9967552883, green: 0.9521791773, blue: 1, alpha: 1)
            valueView.textAlignment = .right
            valueView.font = UIFont.boldSystemFont(ofSize: font_size)
            
            // CREATE new Button DELETE:
            let deleteButton = UIButton(frame: CGRect(x: 0, y: ((subViewHeight + spacing) * i) + 50, width: label_length / 2 - 50, height: 30))
            deleteButton.tintColor = UIColor.black
            deleteButton.backgroundColor = #colorLiteral(red: 0.7207441926, green: 0.02335692724, blue: 0.06600695687, alpha: 1)
            deleteButton.setTitle("X", for: UIControl.State.normal)
            deleteButton.isEnabled = true
//            deleteButton.isHighlighted = true
            deleteButton.showsTouchWhenHighlighted = true
            deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
            button_keys.insert(deleteButton.description, at: i)
            asset_keys.insert(data.assetname, at: i)
            
            // Add the views:
            self.scrollView.addSubview(view)
            self.scrollView.addSubview(nameView)
            self.scrollView.addSubview(typeView)
            self.scrollView.addSubview(valueView)
            self.scrollView.addSubview(deleteButton)
            
            i += 1
        }
    }
    
    // Formats money (Euro):
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
    
    // Checks if an object should be deleted or not
    @objc func deleteAction(_ sender: UIButton) {
        var toDelete = ""
        tapped_button = sender.description              // SEHR WICHTIG!
        
        for i in 0...button_keys.count-1 {
            if tapped_button == button_keys[i] {
                toDelete = asset_keys[i]!
                break
            }
        }
        let message = "Asset '\(toDelete)' wirklich löschen?"
        let alert = UIAlertController(title: "⚠️ Asset löschen?", message: message, preferredStyle: .alert)
        print("[i] Showing delete-asset alert ⚠️:")
        alert.addAction(UIAlertAction(title: "NEIN ❌", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ja ✅", style: .default, handler: deleteData(_:)))
        self.present(alert, animated: true)
    }
    
    // Takes care of DELETING the last clicked asset:
    func deleteData(_ entity: UIAlertAction) {
        var toDelete = ""
        
        for i in 0...button_keys.count-1 {
            if tapped_button == button_keys[i] {
                toDelete = asset_keys[i]!
                break
            }
        }
        
        // Try deleting!
        if let result = try? context.fetch(fetchRequest) as? [Asset] {
            for object in result {
                if object.assetname == toDelete {
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
        
        // RESETS THE VIEW:
        assets = []
        scrollViewData = []
        let allSubViews = self.scrollView.subviews
        for subView in allSubViews {
            subView.removeFromSuperview()
        }
        self.viewDidLoad()
    }
    
    // FOR STATUS BAR "STATUS"
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
// CLASS END #################################################################


// The VIEW for the assets:
class AssetView: UIView {
    
    // INIT:
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
