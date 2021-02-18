//
//  GoodsJSONEntity.swift
//  Geck Retail
//
//  Created by Prof. Dr. Nunkesser, Robin on 27.01.18.
//  Copyright © 2018 Hochschule Hamm-Lippstadt. All rights reserved.
//

import Foundation

struct GoodsJSONEntity : Codable {
    var ean : String
    var priceRewe : Double
    var priceEdeka : Double
    var image : String
    var priority : Double
    var nameD : String
    var synonymsD : String
    var categoryD: String
}
