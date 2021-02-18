//
//  GoodsViewModel+CoreDataProperties.swift
//  
//
//  Created by Ognjen Milovanovic on 29.09.19.
//
//

import Foundation
import CoreData


extension GoodsViewModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GoodsViewModel> {
        return NSFetchRequest<GoodsViewModel>(entityName: "GoodsViewModel")
    }

    @NSManaged public var category: String?
    @NSManaged public var image: String?
    @NSManaged public var inCart: Bool
    @NSManaged public var priceEdeka: Double
    @NSManaged public var priceRewe: Double
    @NSManaged public var priority: Double
    @NSManaged public var quantity: Int16
    @NSManaged public var selected: Bool
    @NSManaged public var synonyms: String?
    @NSManaged public var totalPrice: Double

}
