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

protocol Transaction: Chainable, Codable {
	var type: TransactionType { get }
    static func stype() -> TransactionType
}

protocol Transactionable {
    func toTransaction() -> Transaction
}

extension Transaction {
    static func fromTransaction<T>(_ t: Transaction) -> T? {
        guard let transaction = t as? T else { return nil }
        return transaction
    }
}
