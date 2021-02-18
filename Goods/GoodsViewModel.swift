//
//  GoodsViewModel.swift
//  Geck Retail
//
//  Created by Prof. Dr. Nunkesser, Robin on 27.01.18.
//  Copyright © 2018 Hochschule Hamm-Lippstadt. All rights reserved.
//

import Foundation
import os.log
class GoodsViewModel {
    var ean : String
    var priceRewe : Double
    var priceEdeka : Double
    var image : String
    var priority : Double
    var name : String
    var synonyms : String
    var category: String
    var selected: Bool = false
    var inCart: Bool = false
    var quantity: Int = 1
    var totalPrice: Double {
        return priceRewe * (Double)(quantity)
    }

    
 
    


    init(ean :String,priceRewe: Double,priceEdeka: Double, image: String, priority: Double, name: String, synonyms: String, category: String,selected: Bool) {
        self.ean = ean
        self.priceRewe = priceRewe
        self.priceEdeka = priceEdeka
        self.image = image
        self.priority = priority
        self.name = name
        self.synonyms = synonyms
        self.category = category
        self.selected = selected        
    }
    
    func similarity(term: String) -> Int {
        var value = -name.count
        if (name.lowercased().hasPrefix(term.lowercased())) {
            value += 1000
        } else if (name.lowercased().contains(term.lowercased())) {
            value += 500
        }
        if (synonyms.lowercased().contains(term.lowercased())) {
            value += 250
        }
        return value
    }
}
