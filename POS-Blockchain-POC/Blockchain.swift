//
//  Blockchain.swift
//  POS-Blockchain-POC
//
//  Created by Jonathan Oliveira on 22/06/19.
//  Copyright © 2019 Jonathan Oliveira. All rights reserved.
//

struct Blockchain {

    struct Block: Chainable {
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

    private var blockchain: [Block] = []
    private var listeners: [(TransactionType, (Transaction) -> Void)] = []
    
    var size: Int { return blockchain.count }

    mutating func mineBlockWith(_ ts: [Transaction]) {
        let block = generateBlock(ts)
        append(block: block)
        encodeAndBroadcast(block)
    }

    func transactionsOf(type: TransactionType) -> [Transaction] {
        return blockchain |> flatMap { $0.transactions } >>> filter { $0.type == type }
    }

    mutating func add(transaction: Transaction) {
        /// right now, all blocks are made of a single transaction. This should change for performance.
        let _ = mineBlockWith([transaction])
    }

    mutating func append(block: Block) {
        blockchain.append(block) /// should check to see if they can be added!
        notifyListeners(with: block)
    }

    mutating func listen<A: Transaction>(for tt: A.Type, with listener: @escaping (Transaction) -> Void) -> [A] {
        listeners.append((tt.stype(), listener))
        return transactionsOf(type: tt.stype()).compactMap(A.fromTransaction(_:))
    }
}

private extension Blockchain {
    func notifyListeners(with block: Block) {
        block.transactions.forEach { transaction in
            let liveListeners = listeners.filter{ $0.0 == transaction.type }
            liveListeners.forEach{ $0.1(transaction) }
        }
    }

    func encodeAndBroadcast(_ block: Block) {
        guard let blockData = try? JSONEncoder().encode(block) else { return }
        LocalServer.shared.broadcast(blockData)
    }

    func generateBlock(_ ts: [Transaction]) -> Block {
        let previousHash = blockchain.count > 0 ? blockchain.last!.blockHash : 0
        return Block(transactions: ts, parentHash: previousHash)
    }
}

extension Blockchain.Block: Codable {
    private enum CodingKeys : CodingKey {
        case transactions
        case parentHash
        case blockHash
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        transactions = try container.decode([TransactionWrapper].self, forKey: .transactions)
            .map { $0.transaction }
        parentHash = try container.decode(Int.self, forKey: .parentHash)
        blockHash = try container.decode(Int.self, forKey: .blockHash)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(transactions.map(TransactionWrapper.init), forKey: .transactions)
        try container.encode(parentHash, forKey: .parentHash)
        try container.encode(blockHash, forKey: .blockHash)
    }
}

private struct TransactionWrapper: Codable {
    var transaction: Transaction

    init(_ transaction: Transaction) {
        self.transaction = transaction
    }

    private enum CodingKeys : CodingKey {
        case type, transaction
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(TransactionType.self, forKey: .type)
        transaction = try type.metatype.init(from: container.superDecoder(forKey: .transaction))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(transaction.type, forKey: .type)
        try transaction.encode(to: container.superEncoder(forKey: .transaction))
    }
}
