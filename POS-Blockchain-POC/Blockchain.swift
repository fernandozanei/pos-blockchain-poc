//
//  Blockchain.swift
//  POS-Blockchain-POC
//
//  Created by Jonathan Oliveira on 22/06/19.
//  Copyright © 2019 Jonathan Oliveira. All rights reserved.
//

struct Blockchain {
	private var blockchain: [Block] = []
	
	mutating func mineBlockWith(_ ts: [Transaction]) -> (Int, Int) {
		let block = generateBlock(ts)
		blockchain.append(block)
		return (block.parentHash, block.blockHash)
	}
	
	private func generateBlock(_ ts: [Transaction]) -> Block {
		let previousHash = blockchain.count > 0 ? blockchain.last!.blockHash : 0
		return Block(transactions: ts, parentHash: previousHash)
	}
	
	func size() -> Int {
		return blockchain.count
	}
}

extension Blockchain {
	private struct Block: Chainable {
		let transactions: [Transaction]
		let parentHash: Int
		let blockHash: Int
		
		init(transactions: [Transaction], parentHash: Int) {
			self.transactions = transactions
			self.parentHash = parentHash
			var hasher = Hasher()
			hasher.combine(parentHash)
			transactions |> map { $0.hash() } >>> forEach { hasher.combine($0) }
			blockHash = hasher.finalize()
		}
		
		func hash() -> Int { return blockHash }
	}
}
