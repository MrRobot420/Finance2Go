//
//  Asset+CoreDataProperties.swift
//  Finance 2 Go
//
//  Created by Maximilian Karl on 18.05.19.
//  Copyright © 2019 RobotSystems. All rights reserved.
//
//

import Foundation
import CoreData


extension Asset {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Asset> {
        return NSFetchRequest<Asset>(entityName: "Asset")
    }

    @NSManaged public var id: Int32
    @NSManaged public var assetname: String?
    @NSManaged public var profilename: String?
    @NSManaged public var value: Double
    @NSManaged public var type: String?
    @NSManaged public var belongsTo: Profile?
    @NSManaged public var addsUpTo: Target?
    @NSManaged public var has: Transaction?

}
