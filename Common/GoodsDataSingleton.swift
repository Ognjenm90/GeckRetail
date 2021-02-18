//
//  GoodsDataSingleton.swift
//  Geck Retail
//
//  Created by Prof. Dr. Nunkesser, Robin on 30.01.18.
//  Copyright © 2018 Hochschule Hamm-Lippstadt. All rights reserved.
//

import Foundation

class GoodsDataSingleton {
    
    static let sharedInstance = GoodsDataSingleton()
    
    var goods:[GoodsJSONEntity] = []
    
    var sharedGoods:[GoodsViewModel] = []
    
    var loadedData : Int?
    
    init() {
    }
    
}
