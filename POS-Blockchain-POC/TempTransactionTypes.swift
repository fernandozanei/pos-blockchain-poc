//
//  TempTransactionTypes.swift
//  POS-Blockchain-POC
//
//  Created by Jonathan Oliveira on 24/06/19.
//  Copyright © 2019 Jonathan Oliveira. All rights reserved.
//

struct MenuItem: Transaction, Hashable {
	let type: TransactionType = .menu_item
	let name: String
	let price: Double

	func hash() -> Int {
		return self.hashValue
	}

    static func stype() -> TransactionType {
        return .menu_item
    }
}

struct Staff: Hashable {
	enum Role { case admin, waiter }
	let name: String
	let role: Role
}

struct StaffAction: Transaction, Hashable {
	enum Action { case login, logout }
	let type: TransactionType = .staff_action
	let staff: Staff
	let action: Action
	
	func hash() -> Int {
		return self.hashValue
	}

    static func stype() -> TransactionType {
        return .staff_action
    }
}

struct TableState: Transaction, Hashable {
    let type: TransactionType = .table_state
    let number: Int
    let isOpen: Bool
    
    func hash() -> Int {
        return self.hashValue
    }

    static func stype() -> TransactionType {
        return .table_state
    }
}
