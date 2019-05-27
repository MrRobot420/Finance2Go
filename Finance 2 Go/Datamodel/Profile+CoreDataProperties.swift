//
//  Profile+CoreDataProperties.swift
//  Finance 2 Go
//
//  Created by Maximilian Karl on 26.05.19.
//  Copyright © 2019 RobotSystems. All rights reserved.
//
//

import Foundation
import CoreData


extension Profile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Profile> {
        return NSFetchRequest<Profile>(entityName: "Profile")
    }

    @NSManaged public var age: Int16
    @NSManaged public var email: String?
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var password: String?
    @NSManaged public var isOwnerOf: Asset?

}
