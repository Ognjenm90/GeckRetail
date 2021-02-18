//
//  GoodsData.swift
//  Geck Retail
//
//  Created by Ognjen Milovanovic on 28.10.19.
//  Copyright © 2019 Hochschule Hamm-Lippstadt. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class GoodsData{
    
    static let sharedInstance = GoodsData()
    //Data aus Firebase nehmen
     func callFirebaseToFetchNewData(completion: @escaping () -> Void){
        Database.database().reference().child("geckfood").observe(.value, with: {(snapshot)
            in
             var goods = [GoodsJSONEntity]()
                for g in snapshot.children.allObjects as![DataSnapshot]{
                    
                    let goodObject = g.value as? [String:AnyObject]
                    let ean =  goodObject?["ean"]
                    let priceRewe = goodObject?["priceRewe"]
                    let priceEdeka = goodObject?["priceEdeka"]
                    let image = goodObject?["image"]
                    let priority = goodObject?["priority"]
                    let nameD = goodObject?["nameD"]
                    let synonymsD = goodObject?["synonymsD"]
                    let categoryD = goodObject?["categoryD"]
                  
                    let good = GoodsJSONEntity(ean: ean as! String,priceRewe: priceRewe as! Double, priceEdeka: priceEdeka as! Double, image: image as! String, priority: priority as! Double, nameD: nameD as! String, synonymsD: synonymsD as! String, categoryD: categoryD as! String)
                    //Data in goods Array packen um es später in GoodsViewController zu nutzen
                    goods.append(good)
                
                    GoodsDataSingleton.sharedInstance.goods = goods
                    GoodsDataSingleton.sharedInstance.sharedGoods = goods.map(GoodsPresenter.present)
                 
                }
                completion()
            })
    }
    init() {
    }}
