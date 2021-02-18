//
//  Gateway.swift
//  Hochschulapp
//
//  Created by Prof. Dr. Nunkesser, Robin on 05.07.17.
//  Copyright © 2017 Hochschule Hamm-Lippstadt. All rights reserved.
//

enum GatewayResponse<Value> {
    case success(Value)
    case failure(Error)
}

enum Failure: String, Error {
    case noData = "NoData.error"
}


