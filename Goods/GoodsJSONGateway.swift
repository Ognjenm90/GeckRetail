//
//  GoodsJSONGateway.swift
//  Geck Retail
//
//  Created by Prof. Dr. Nunkesser, Robin on 27.01.18.
//  Copyright © 2018 Hochschule Hamm-Lippstadt. All rights reserved.
//

import Foundation

struct GoodsJSONGateway {
    
    func fetchGoods(resourceName: String) -> GatewayResponse<[GoodsJSONEntity]> {
                
        if let path = Bundle.main.path(forResource: resourceName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoder = JSONDecoder()
                let goods = try decoder.decode([GoodsJSONEntity].self,
                                               from: data)
          
                return GatewayResponse<[GoodsJSONEntity]>.success(goods)
            } catch {
                print(error)
                return GatewayResponse<[GoodsJSONEntity]>.failure(error)
            }
            
        }
        return GatewayResponse<[GoodsJSONEntity]>.failure(Failure.noData)
        
    }
    
}
