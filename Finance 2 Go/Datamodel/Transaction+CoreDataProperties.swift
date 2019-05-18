//
//  Transaction+CoreDataProperties.swift
//  Finance 2 Go
//
//  Created by Maximilian Karl on 18.05.19.
//  Copyright © 2019 RobotSystems. All rights reserved.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var id: Int32
    @NSManaged public var assetname: String?
    @NSManaged public var from: String?
    @NSManaged public var to: String?
    @NSManaged public var title: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var value: Double
    @NSManaged public var type: String?
    @NSManaged public var isPartOf: Asset?

}
