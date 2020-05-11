//
//  MenuTableViewController.swift
//  POS-Blockchain-POC
//
//  Created by Fernando Zanei on 2020-05-10.
//  Copyright © 2020 Jonathan Oliveira. All rights reserved.
//

import UIKit

protocol MenuTableViewControllerDelegate: AnyObject {
    func didSelectMenuItem(_ menutItem: MenuItemModel)
}

class MenuTableViewController: UITableViewController {
    
    private let cellID = "cellID"
    weak var delegate: MenuTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "MENU"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kMenuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
        cell.textLabel?.text = kMenuItems[indexPath.row].name
        cell.detailTextLabel?.text = String(kMenuItems[indexPath.row].price)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectMenuItem(kMenuItems[indexPath.row])
//        let transaction = MenuItemTransaction(name: menuItem.name, price: menuItem.price)
//        blockchain.add(transaction: transaction)
    }
}
