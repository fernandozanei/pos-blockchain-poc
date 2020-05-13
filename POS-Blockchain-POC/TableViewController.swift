//
//  TableViewController.swift
//  POS-Blockchain-POC
//
//  Created by Fernando Zanei on 2020-05-10.
//  Copyright © 2020 Jonathan Oliveira. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
    
    private let listContainer = UIView()
    private var listContent: UINavigationController?

    private let formContainer = UIView()
    private var formContent: UINavigationController?

    private var listVC: MenuTableViewController!
    private var formVC: OrderTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        let button = UIButton()
        button.backgroundColor = .red
        button.setTitle("OK", for: .normal)

        view.addSubview(button)
        button.anchor(leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: 66))
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            let transactions = formVC.menuItems |> map { MenuItemTransaction(name: $0.name, price: $0.price) }
            blockchain.add(transactions: transactions)
            blockchain.mineBlock()
        }
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
    }
}

extension TableViewController: MenuTableViewControllerDelegate {
    func didSelectMenuItem(_ menutItem: MenuItemModel) {
        formVC.menuItems.append(menutItem)
    }
}
