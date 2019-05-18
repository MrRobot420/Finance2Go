//
//  Target+CoreDataProperties.swift
//  Finance 2 Go
//
//  Created by Maximilian Karl on 18.05.19.
//  Copyright © 2019 RobotSystems. All rights reserved.
//
//

import Foundation
import CoreData


extension Target {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Target> {
        return NSFetchRequest<Target>(entityName: "Target")
    }

    @NSManaged public var id: Int32
    @NSManaged public var assetname: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var value: Double
    @NSManaged public var rate: Double
    @NSManaged public var consitsOf: Asset?

}
