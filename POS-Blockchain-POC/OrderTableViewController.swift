//
//  OrderTableViewController.swift
//  POS-Blockchain-POC
//
//  Created by Fernando Zanei on 2020-05-10.
//  Copyright © 2020 Jonathan Oliveira. All rights reserved.
//

import UIKit

class OrderTableViewController: UIViewController {
    
    var menuItems: [MenuItemModel] = [] {
        didSet {
            let total = menuItems.reduce(0) { $0 + $1.price }
            subTotalValueLabel.text = "$\(total)"
            tableView.reloadData()
        }
    }
    
    private let cellID = "cellID"
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let subTotalLabel: UILabel = {
        let label = UILabel()
        label.text = "Subtotal:"
        label.font = .boldSystemFont(ofSize: 17)
        return label
    }()
    
    private let subTotalValueLabel: UILabel = {
        let label = UILabel()
        label.text = "$0"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "TEST"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        let totalView = UIStackView(arrangedSubviews: [subTotalLabel, UIView(), subTotalValueLabel])
        totalView.axis = .horizontal
        totalView.distribution = .fillProportionally
        
        view.addSubview(totalView)
        totalView.anchor(leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: 44))
        
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: totalView.topAnchor, trailing: view.trailingAnchor)
    }
}

extension OrderTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
        cell.textLabel?.text = menuItems[indexPath.row].name
        cell.detailTextLabel?.text = String(menuItems[indexPath.row].price)
        
        return cell
    }
}

extension OrderTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            menuItems.remove(at: indexPath.row)
        }
    }
    
}
