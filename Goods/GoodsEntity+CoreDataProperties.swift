//
//  GoodsEntity+CoreDataProperties.swift
//  
//
//  Created by Ognjen Milovanovic on 30.09.19.
//
//

import Foundation
import CoreData


extension GoodsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoodsEntity> {
        return NSFetchRequest<GoodsEntity>(entityName: "GoodsEntity")
    }

    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var priceEdeka: Double
    @NSManaged public var priceRewe: Double
    @NSManaged public var priority: Int16
    @NSManaged public var synonyms: String?
    @NSManaged public var category: CategoryEntity?

}
