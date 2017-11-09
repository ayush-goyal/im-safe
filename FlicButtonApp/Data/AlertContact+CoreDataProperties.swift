//
//  AlertContact+CoreDataProperties.swift
//  
//
//  Created by Macbook on 11/8/17.
//
//

import Foundation
import CoreData


extension AlertContact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AlertContact> {
        let request = NSFetchRequest<AlertContact>(entityName: "AlertContact")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
    }

    @NSManaged public var name: String?
    @NSManaged public var number: String?

}
