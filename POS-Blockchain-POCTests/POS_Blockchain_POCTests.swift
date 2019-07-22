//
//  POS_Blockchain_POCTests.swift
//  POS-Blockchain-POCTests
//
//  Created by Jonathan Oliveira on 22/06/19.
//  Copyright © 2019 Jonathan Oliveira. All rights reserved.
//

import XCTest
@testable import POS_Blockchain_POC

class POS_Blockchain_POCTests: XCTestCase {
    
    var blockchain: Blockchain!
    let nachos = MenuItem(name: "Nachos", price: 12.99)
    let manager = Staff(name: "Jon", role: .admin)
    let salad = MenuItem(name: "Salad", price: 5.99)

    override func setUp() {
        blockchain = Blockchain()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCanCreateGenesisBlock() {
        let loginAdmin = StaffAction(staff: manager, action: .login)
        let (b1_parent_hash, _) = blockchain.mineBlockWith([nachos, loginAdmin])
        XCTAssert(b1_parent_hash == 0)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testCanGenerateChain() {
        let loginAdmin = StaffAction(staff: manager, action: .login)
        let (b1_parent_hash, b1_hash) = blockchain.mineBlockWith([nachos, loginAdmin])
        let (b2_parent_hash, b2_hash) = blockchain.mineBlockWith([salad])
        let logoutAdmin = StaffAction(staff: manager, action: .logout)
        let (b3_parent_hash, b3_hash) = blockchain.mineBlockWith([logoutAdmin])
        XCTAssert(b1_parent_hash == 0)
        XCTAssert(b1_hash == b2_parent_hash)
        XCTAssert(b2_hash == b3_parent_hash)
        XCTAssert(b3_hash != b1_parent_hash && b3_hash != b1_hash && b3_hash != b1_hash)
    }
    
    func testCanCountBlocks() {
        let loginAdmin = StaffAction(staff: manager, action: .login)
        let _ = blockchain.mineBlockWith([nachos, loginAdmin])
        let _ = blockchain.mineBlockWith([salad])
        let logoutAdmin = StaffAction(staff: manager, action: .logout)
        let _ = blockchain.mineBlockWith([logoutAdmin])
        XCTAssert(blockchain.size == 3)
    }
    
    func testCanReadTransaction() {
        let loginAdmin = StaffAction(staff: manager, action: .login)
        let _ = blockchain.mineBlockWith([nachos, loginAdmin])
        let _ = blockchain.mineBlockWith([salad])
        let logoutAdmin = StaffAction(staff: manager, action: .logout)
        let _ = blockchain.mineBlockWith([logoutAdmin])
        let menuitem: MenuItem = blockchain.transactionsOf(type: .menu_item).compactMap(MenuItem.fromTransaction(_:)).first!
        let staff_action: StaffAction = blockchain.transactionsOf(type: .staff_action).compactMap(StaffAction.fromTransaction(_:)).last!
        XCTAssert(menuitem == nachos)
        XCTAssert(staff_action == logoutAdmin)
    }
}
