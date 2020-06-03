//
//  ClosedOrderTableViewController.swift
//  POS-Blockchain-POC
//
//  Created by Jonathan Oliveira on 2020-05-15.
//  Copyright © 2020 Jonathan Oliveira. All rights reserved.
//

import UIKit

class ClosedOrderTableViewController: UITableViewController {

    private let cellId = "cellId"
    private var orders: [OrderTransaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(OrderCell.self, forCellReuseIdentifier: cellId)

        orders = blockchain.queryAllBlocks { transaction in
            guard let transaction = transaction as? OrderTransaction else { return false }

            return !transaction.isOpen
        }.compactMap { $0 as? OrderTransaction }

        blockchain.listen(for: OrderTransaction.self, with: closedOrderListener)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? OrderCell
        cell?.loadOrder(orders[indexPath.row])
        return cell!
    }

    func closedOrderListener(_ transaction: Transaction) {
        guard let order = transaction as? OrderTransaction else { return }

        orders.append(order)
        tableView.reloadData()
    }
}

class OrderCell: UITableViewCell {
    private let tableNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "Table 1"
        return label
    }()

    private let orderValueLabel: UILabel = {
        let label = UILabel()
        label.text = "$500.21"
        return label
    }()

    func loadOrder(_ order: OrderTransaction) {
        selectionStyle = .none

        addSubview(tableNumberLabel)
        tableNumberLabel.anchor(top: topAnchor, leading: leadingAnchor, padding: .init(top: 11, left: 11, bottom: 0, right: 0))
        tableNumberLabel.text = "Table \(order.tableId)"
        
        let itemsLabels: [UILabel] = order.menuItems.map {
            let label = UILabel()
            label.text = $0.name
            return label
        }

        let stack = UIStackView(arrangedSubviews: itemsLabels)
        stack.axis = .vertical

        addSubview(stack)
        stack.anchor(top: tableNumberLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, padding: .init(top: 11, left: 11, bottom: 11, right: 11))

        addSubview(orderValueLabel)
        orderValueLabel.anchor(trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 11))
        orderValueLabel.centerYSuperview()
        orderValueLabel.text = "$ \(order.menuItems.map{$0.price}.reduce(0, +))"
    }
}
