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
    private var openTransactions: [Transaction] = []
    private var listeners: [(TransactionType, (Transaction) -> Void)] = []
    private var fullListeners: [(TransactionType, ([Transaction]) -> Void)] = []
    
    var size: Int { return blockchain.count }

    mutating func mineBlock() {
        guard !openTransactions.isEmpty else { return }

        let block = generateBlock(openTransactions)
        append(block: block)
        openTransactions = []
        encodeAndBroadcast(block)
    }

    mutating func update(with blockchain: [Block]) {
        guard let firstBlock = blockchain.first, firstBlock.parentHash == 0 else { return }

        self.blockchain = blockchain
        notifyFullListenersOf(type: .table_state)
    }

    mutating func add(transaction: Transaction) {
        /// right now, all blocks are made of a single transaction. This should change for performance.
        openTransactions.append(transaction)
    }
    
    mutating func add(transactions: [Transaction]) {
        /// right now, all blocks are made of a single transaction. This should change for performance.
        openTransactions.append(contentsOf: transactions)
    }
    
    func queryFirstBlock(where predicate: @escaping (Transaction) -> Bool) -> [Transaction] {
        var filteredTransactions: [Transaction] = []
        
        for block in blockchain.reversed() {
            guard block.transactions.contains(where: predicate) else { continue }
            
            filteredTransactions.append(contentsOf: block.transactions.filter(predicate))
            break
        }
        
        return filteredTransactions
    }

    mutating func append(block: Block) {
        let isGenesisBlock = block.parentHash == 0
        let canBeAppended = block.parentHash == blockchain.last?.blockHash
        guard isGenesisBlock || canBeAppended else { return }

        blockchain.append(block)
        notifyListeners(with: block)
    }

    mutating func listen<A: Transaction>(for tt: A.Type, with listener: @escaping (Transaction) -> Void) {
        listeners.append((tt.stype(), listener))
    }

    mutating func listen<A: Transaction>(for tt: A.Type, with listener: @escaping ([Transaction]) -> Void) {
        fullListeners.append((tt.stype(), listener))
    }

    func encodeBlockchain() -> Data? {
        try? JSONEncoder().encode(blockchain)
    }
}

private extension Blockchain {
    func notifyListeners(with block: Block) {
        block.transactions.forEach { transaction in
            let liveListeners = listeners.filter{ $0.0 == transaction.type }
            liveListeners.forEach{ $0.1(transaction) }
        }
    }

    func notifyFullListenersOf(type: TransactionType) {
        let reversedTransactions = blockchain.reversed() |> flatMap { $0.transactions }

        switch type {
        case .menu_item: break
        case .staff_action: break
        case .table_state:
            let tableStateTransactions = reversedTransactions |> compactMap { $0 as? TableState }

            var latestTransactions: [TableState] = []
            tableStateTransactions.forEach { transaction in
                if !latestTransactions.contains(where: { $0.number == transaction.number }) {
                    latestTransactions.append(transaction)
                }
            }

            fullListeners
                .filter { $0.0 == type }
                .forEach { $0.1(latestTransactions) }
        }
    }

    func encodeAndBroadcast(_ block: Block) {
        guard let dataBlock = try? JSONEncoder().encode(block) else { return }
        LocalServer.shared.broadcast(dataBlock, path: .block)
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
