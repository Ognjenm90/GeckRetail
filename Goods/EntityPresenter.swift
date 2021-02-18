//
//  EntityPresenter.swift
//  Geck Retail
//
//  Created by Ognjen Milovanovic on 29.09.19.
//  Copyright © 2019 Hochschule Hamm-Lippstadt. All rights reserved.
//

import Foundation

struct EntityPresenter  {
    
    typealias Entity = GoodsJSONEntity
    typealias ViewModel = GoodsViewModel
    

    
    static func present(viewModel: GoodsViewModel) -> GoodsJSONEntity {
        return  GoodsJSONEntity(ean:viewModel.ean,priceRewe: viewModel.priceRewe,priceEdeka: viewModel.priceEdeka, image: viewModel.image, priority: viewModel.priority, nameD: viewModel.name, synonymsD: viewModel.synonyms, categoryD: viewModel.category)
    }
    
}
