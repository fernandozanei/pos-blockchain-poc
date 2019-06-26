//
//  TempTransactionTypes.swift
//  POS-Blockchain-POC
//
//  Created by Jonathan Oliveira on 24/06/19.
//  Copyright © 2019 Jonathan Oliveira. All rights reserved.
//

struct MenuItem: Transaction, Hashable {
	let name: String
	let price: Double
	
	func hash() -> Int {
		return self.hashValue
	}
}

struct Staff: Hashable {
	enum Role { case admin, waiter }
	let name: String
	let role: Role
}

struct StaffAction: Transaction, Hashable {
	enum Action { case login, logout }
	let staff: Staff
	let action: Action
	
	func hash() -> Int {
		return self.hashValue
	}
}