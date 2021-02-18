//
//  GoodsInteractor.swift
//  Geck Retail
//
//  Created by Prof. Dr. Nunkesser, Robin on 27.01.18.
//  Copyright © 2018 Hochschule Hamm-Lippstadt. All rights reserved.
//

import Foundation

struct GoodsInteractor {

   
    let userDefaults = UserDefaults.standard
    
    func fetchGoods() -> GatewayResponse<[GoodsJSONEntity]> {
        var resourceName : String
        let database = userDefaults.integer(
            forKey: "databasePreference")
        switch database {
        case 0:
            resourceName = "geckfood"
        case 1:
            resourceName = "ecofood"
        default:
            resourceName = "food"
        }
       // let response = GoodsJSONGateway().fetchGoods(resourceName: resourceName)
       let response = GoodsJSONGateway().fetchGoods(resourceName: resourceName)
        switch response {
        case .success(_):
            GoodsDataSingleton.sharedInstance.loadedData = database
        case .failure(_): break
        }
        
        return response
    }        
    
}
