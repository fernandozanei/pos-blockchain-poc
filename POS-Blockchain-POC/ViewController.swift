//
//  ViewController.swift
//  POS-Blockchain-POC
//
//  Created by Jonathan Oliveira on 22/06/19.
//  Copyright © 2019 Jonathan Oliveira. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let serverButton: UIButton = {
        let button = UIButton()
        button.setTitle("Init BC", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(newBC), for: .touchUpInside)
        return button
    }()
    
    let clientButton: UIButton = {
        let button = UIButton()
        button.setTitle("Join BC", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(joinBC), for: .touchUpInside)
        return button
    }()
    
    @objc func newBC() {
//        bc = Blockchain()
        // start multipeer browse
        // segue login
    }
    
    @objc func joinBC() {
        // search and get bc from multipeer
        //segue login
    }

    override func viewDidLoad() {
		super.viewDidLoad()
    
        view.addSubview(serverButton)
        serverButton.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 100, left: 100, bottom: 0, right: 0), size: .init(width: 200, height: 200))
        
        view.addSubview(clientButton)
        clientButton.anchor(top: view.topAnchor, leading: serverButton.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 100, left: 100, bottom: 0, right: 0), size: .init(width: 200, height: 200))
		
		let nodeUUID = NSUUID().uuidString
        print(nodeUUID)
        _ = Genesis(nodeName: nodeUUID)
		
		testingBlockchain()

	}
	
	func testingBlockchain() {
		let nachos = MenuItem(name: "Nachos", price: 12.99)
		let manager = Staff(name: "Jon", role: .admin)
		let loginAdmin = StaffAction(staff: manager, action: .login)
		
		let (b1_parent_hash, b1_hash) = blockchain.mineBlockWith([nachos, loginAdmin])
		print("<BK Testing> block 1 parent hash:", b1_parent_hash)
		print("<BK Testing> block 1 hash:", b1_hash)
		
		print("<BK Testing> -------")
		print("<BK Testing> -------")
		
		let salad = MenuItem(name: "Salad", price: 5.99)
		let (b2_parent_hash, b2_hash) = blockchain.mineBlockWith([salad]);
		print("<BK Testing> block 2 parent hash:", b2_parent_hash)
		print("<BK Testing> block 2 hash:", b2_hash)
		
		print("<BK Testing> -------")
		print("<BK Testing> -------")
		
		let logoutAdmin = StaffAction(staff: manager, action: .logout)
		let (b3_parent_hash, b3_hash) = blockchain.mineBlockWith([logoutAdmin])
		print("<BK Testing> block 3 parent hash:", b3_parent_hash)
		print("<BK Testing> block 3 hash:", b3_hash)
		
		print("<BK Testing> -------")
		print("<BK Testing> -------")
		
		print("<BK Testing> blockchain size:", blockchain.size)
		
		let menuItems = blockchain.transactionsOf(type: .menu_item)
		let staffActions = blockchain.transactionsOf(type: .staff_action)
		
		print("<BK Testing> \(menuItems.count) menu items", menuItems)
		print("<BK Testing> \(staffActions.count) staff actions", staffActions)
	}


}

