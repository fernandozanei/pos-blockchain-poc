//
//  TableViewController.swift
//  POS-Blockchain-POC
//
//  Created by Fernando Zanei on 2020-05-10.
//  Copyright © 2020 Jonathan Oliveira. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
    
    private let tableId: Int
    
    private let listContainer = UIView()
    private var listContent: UINavigationController?

    private let formContainer = UIView()
    private var formContent: UINavigationController?
    private var isClosingOrder: Bool = false

    private var listVC: MenuTableViewController!
    private var formVC: OrderTableViewController!

    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.setTitle("Close Order", for: .normal)
        button.addTarget(self, action: #selector(closeOrder(_:)), for: .touchUpInside)
        return button
    }()
    
    init(tableId: Int) {
        self.tableId = tableId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(button)
        button.anchor(leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -34, right: 0), size: .init(width: 0, height: 134))
        
        view.addSubview(listContainer)
        
        listContainer.anchor(top: view.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: button.topAnchor)
        listContainer.constraintWidth(equalTo: view.widthAnchor, multiplier: 0.5)
        
        let line = UIView()
        view.addSubview(line)
        line.anchor(top: view.topAnchor, leading: listContainer.trailingAnchor, bottom: button.topAnchor, size: .init(width: 0.5, height: 0))
        
        view.addSubview(formContainer)
        formContainer.anchor(top: view.topAnchor, leading: line.trailingAnchor, bottom: button.topAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)

        loadListVC()
        loadFormVC()
    }
    
    @objc fileprivate func closeOrder(_ sender: UIButton?) {
        if !formVC.menuItems.isEmpty {
            let menuItems = formVC.menuItems |> map { MenuItemTransaction(name: $0.name, price: $0.price) }
            let order = OrderTransaction(
                tableId: tableId,
                isOpen: sender != nil ? false : (menuItems.isEmpty ? false : true),
                menuItems: menuItems)
            blockchain.add(transaction: order)
        }

        blockchain.add(transaction: TableState(number: tableId, isOpen: false))
        blockchain.mineBlock()
        isClosingOrder = true

        navigationController?.popViewController(animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent && !isClosingOrder {
            closeOrder(nil)
        }
    }

    private func craeteOrder(isClosed: Bool = true) {
    }

    private func currentMenuItemsQuery(transaction: Transaction) -> Bool {
        guard let order = transaction as? OrderTransaction else { return false }
        
        return order.tableId == tableId
    }
    
    private func loadListVC() {
        if let listContent = listContent {
            listContent.view.removeFromSuperview()
            listContent.removeFromParent()
        }

        listVC = MenuTableViewController(style: .plain)
        listVC.view.backgroundColor = .white
        
        listContent = UINavigationController(rootViewController: listVC)
        addChild(listContent!)
        listContent?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        listContent?.view.frame = .init(x: 0, y: 0, width: listContainer.frame.width, height: listContainer.frame.height)
        listContainer.addSubview(listContent!.view)
        listContent?.didMove(toParent: self)
        
        listVC.delegate = self
    }
    
    private func loadFormVC() {
        formVC = OrderTableViewController()
        formVC.view.backgroundColor = .white

        if UIDevice.current.userInterfaceIdiom == .phone {
            listVC.navigationController?.pushViewController(formVC, animated: true)
        } else {
            if let formContent = formContent {
                formContent.view.removeFromSuperview()
                formContent.removeFromParent()
            }
            
            formContent = UINavigationController(rootViewController: formVC)
            addChild(formContent!)
            formContent?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            formContent?.view.frame = .init(x: 0, y: 0, width: formContainer.frame.width, height: formContainer.frame.height)
            formContainer.addSubview(formContent!.view)
            formContent?.didMove(toParent: self)
        }
        
        let menuItems = blockchain.queryFirstBlock(where: currentMenuItemsQuery(transaction:))
            |> compactMap { $0 as? OrderTransaction }
            >>> filter { $0.isOpen }
            >>> flatMap { $0.menuItems }
            >>> map { MenuItemModel(name: $0.name, price: $0.price) }
        
        formVC.menuItems = menuItems
    }
}

extension TableViewController: MenuTableViewControllerDelegate {
    func didSelectMenuItem(_ menutItem: MenuItemModel) {
        formVC.menuItems.append(menutItem)
    }
}
