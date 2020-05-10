//
//  MenuItemModel.swift
//  POS-Blockchain-POC
//
//  Created by Fernando Zanei on 2020-05-10.
//  Copyright © 2020 Jonathan Oliveira. All rights reserved.
//

import Foundation

struct MenuItemModel: Transactionable {
    
    let name: String
    let price: Double
    
    func toTransaction() -> Transaction {
        MenuItemTransaction(name: name, price: price)
    }
}


let kMenuItems: [MenuItemModel] = [
    MenuItemModel(name: "Coke", price: 2.5),
    MenuItemModel(name: "Sprite", price: 2.5),
    MenuItemModel(name: "Tacos", price: 12.5),
    MenuItemModel(name: "Fries", price: 9.0),
    MenuItemModel(name: "NY Steak", price: 32.5),
    MenuItemModel(name: "Human Liver", price: 200),
    MenuItemModel(name: "Cake", price: 14.5),
    MenuItemModel(name: "Coffee", price: 2.5),
]
