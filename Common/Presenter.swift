//
//  Presenter.swift
//  Geck Retail
//
//  Created by Prof. Dr. Nunkesser, Robin on 27.01.18.
//  Copyright © 2018 Hochschule Hamm-Lippstadt. All rights reserved.
//

import Foundation

protocol Presenter {
    
    associatedtype Entity
    associatedtype ViewModel
    
    static func present(entity: Entity) -> ViewModel
}
