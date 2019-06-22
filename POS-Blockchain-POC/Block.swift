//
//  Block.swift
//  POS-Blockchain-POC
//
//  Created by Jonathan Oliveira on 22/06/19.
//  Copyright © 2019 Jonathan Oliveira. All rights reserved.
//

import Foundation

struct Block {
	let hash: String
	let previousBlockHash: String
	var transactions: [Transaction]
	
	func generateHash() -> String {
		return NSUUID().uuidString.replacingOccurrences(of: "-", with: "")
	}
}
