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

    func hash() -> Int { hashValue }

    static func stype() -> TransactionType { .menu_item }
}

struct Staff: Hashable, Codable {

    enum Role: String, Codable {
        case admin
        case waiter
    }

    let name: String
    let role: Role
}

struct StaffAction: Transaction, Hashable {

    enum Action: String, Codable {
        case login
        case logout
    }

    let type: TransactionType = .staff_action
    let staff: Staff
    let action: Action

    func hash() -> Int { hashValue }

    static func stype() -> TransactionType { .staff_action }
}

struct TableState: Transaction, Hashable {
    let type: TransactionType = .table_state
    let number: Int
    let isOpen: Bool
    
    func hash() -> Int { hashValue }

    static func stype() -> TransactionType { .table_state }
}

enum TransactionType: String, Codable {
    case menu_item
    case staff_action
    case table_state

    var metatype: Transaction.Type {
        switch self {
        case .menu_item:
            return MenuItem.self
        case .staff_action:
            return StaffAction.self
        case .table_state:
            return TableState.self
        }
    }
}
