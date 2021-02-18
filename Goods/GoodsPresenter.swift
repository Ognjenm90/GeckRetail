//
//  GoodsPresenter.swift
//  Geck Retail
//
//  Created by Prof. Dr. Nunkesser, Robin on 27.01.18.
//  Copyright © 2018 Hochschule Hamm-Lippstadt. All rights reserved.
//

import Foundation

struct GoodsPresenter : Presenter {
    
    typealias Entity = GoodsJSONEntity
    typealias ViewModel = GoodsViewModel
    
    
    static func present(entity: GoodsJSONEntity) -> GoodsViewModel {
        return GoodsViewModel(ean:entity.ean,priceRewe: entity.priceRewe,priceEdeka: entity.priceEdeka, image: entity.image, priority: entity.priority, name: entity.nameD, synonyms: entity.synonymsD, category: entity.categoryD,selected: false)
    }
    
 
    
}
