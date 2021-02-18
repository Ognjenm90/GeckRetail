//
//  ShoppingListTableViewCell.swift
//  Geck Retail
//
//  Created by Prof. Dr. Nunkesser, Robin on 01.02.18.
//  Copyright © 2018 Hochschule Hamm-Lippstadt. All rights reserved.
//

import UIKit

class ShoppingListTableViewCell: UITableViewCell {
    
    // MARK: Properties
    static let reuseIdentifier = "GoodsCell"
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var goodsImage: UIImageView!
    @IBOutlet weak var quantityButton: UIButton!
        
}
