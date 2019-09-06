//
//  Blockchain.swift
//  POS-Blockchain-POC
//
//  Created by Jonathan Oliveira on 22/06/19.
//  Copyright © 2019 Jonathan Oliveira. All rights reserved.
//

struct Blockchain {
	
	private var blockchain: [Block] = []
    private var listeners: [(TransactionType, (Transaction) -> Void)] = []
    
    var size: Int { return blockchain.count }
	
	private func generateBlock(_ ts: [Transaction]) -> Block {
		let previousHash = blockchain.count > 0 ? blockchain.last!.blockHash : 0
		return Block(transactions: ts, parentHash: previousHash)
	}
	
	mutating func mineBlockWith(_ ts: [Transaction]) -> (Int, Int) {
		let block = generateBlock(ts)
		blockchain.append(block)
        notifyListeners(with: block)
		return (block.parentHash, block.blockHash)
	}
	
	func transactionsOf(type: TransactionType) -> [Transaction] {
		return blockchain |> flatMap { $0.transactions } >>> filter { $0.type == type }
	}

    mutating func add(transaction: Transaction) {
        let _ = mineBlockWith([transaction])
    }

    mutating func listen<A: Transaction>(for tt: A.Type, with listener: @escaping (Transaction) -> Void) -> [A] {
        listeners.append((tt.stype(), listener))
        return transactionsOf(type: tt.stype()).compactMap(A.fromTransaction(_:))
    }

    private func notifyListeners(with block: Block) {
        block.transactions.forEach { transaction in
            let liveListeners = listeners.filter{ $0.0 == transaction.type }
            liveListeners.forEach{ $0.1(transaction) }
        }
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

enum TransactionType {
	case menu_item
	case staff_action
    case table_state
}
