//
//  Protocols.swift
//  POS-Blockchain-POC
//
//  Created by Jonathan Oliveira on 24/06/19.
//  Copyright © 2019 Jonathan Oliveira. All rights reserved.
//

protocol Chainable {
	func hash() -> Int
}

protocol Transaction: Chainable {}
