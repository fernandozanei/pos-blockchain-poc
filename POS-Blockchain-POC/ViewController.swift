//
//  ViewController.swift
//  POS-Blockchain-POC
//
//  Created by Jonathan Oliveira on 22/06/19.
//  Copyright © 2019 Jonathan Oliveira. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var table1: UIButton!
    private var table2: UIButton!
    private var table3: UIButton!
    private var table4: UIButton!

    override func viewDidLoad() {
		super.viewDidLoad()

        table1 = button(with: "Table 1", id: 1, selector: #selector(pressedAction(_:))) |> blackBackground
        table2 = button(with: "Table 2", id: 2, selector: #selector(pressedAction(_:))) |> blackBackground
        table3 = button(with: "Table 3", id: 3, selector: #selector(pressedAction(_:))) |> blackBackground
        table4 = button(with: "Table 4", id: 4, selector: #selector(pressedAction(_:))) |> blackBackground

        setupTables()

        blockchain.listen(for: TableState.self, with: tableListener)
        blockchain.listen(for: TableState.self, with: fullTableListener)
	}
    
    @objc func pressedAction(_ sender: UIButton!) {
        guard let table = sender as? Table else { return }

        let isOpen = table.backgroundColor == .black ? true : false
        blockchain.add(transaction: TableState(number: table.id, isOpen: isOpen))
        blockchain.mineBlockWith()
        
        navigationController?.pushViewController(TableViewController(), animated: true)
    }

    func fullTableListener(_ transactions: [Transaction]) {
        let tableStates = transactions.compactMap { $0 as? TableState }

        tableStates |> forEach { tableState in
            switch tableState.number {
            case 1: self.table1.backgroundColor = tableState.isOpen ? .red : .black
            case 2: self.table2.backgroundColor = tableState.isOpen ? .red : .black
            case 3: self.table3.backgroundColor = tableState.isOpen ? .red : .black
            default: self.table4.backgroundColor = tableState.isOpen ? .red : .black
            }
        }
    }

    func tableListener(_ transaction: Transaction) {
        guard let table = transaction as? TableState else { return }

        switch table.number {
        case 1: table1.backgroundColor = table.isOpen ? .red : .black
        case 2: table2.backgroundColor = table.isOpen ? .red : .black
        case 3: table3.backgroundColor = table.isOpen ? .red : .black
        default: table4.backgroundColor = table.isOpen ? .red : .black
        }
    }
}

private extension ViewController {
    func setupTables() {
        view.backgroundColor = .white
        
        let tableHeight: CGFloat = 250.0
        let topStack = UIStackView(arrangedSubviews: [table1, table2])
        topStack.distribution = .fillEqually
        topStack.spacing = 24.0
        let topStackTopDistance = (view.frame.size.height / 2) - tableHeight - (topStack.spacing / 2)

        let bottomStack = UIStackView(arrangedSubviews: [table3, table4])
        bottomStack.distribution = .fillEqually
        bottomStack.spacing = 24.0

        view.addSubview(topStack)
        view.addSubview(bottomStack)

        topStack.translatesAutoresizingMaskIntoConstraints = false
        bottomStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: view.topAnchor, constant: topStackTopDistance),
            topStack.widthAnchor.constraint(equalToConstant: tableHeight * 2 + topStack.spacing),
            topStack.heightAnchor.constraint(equalToConstant: tableHeight),
            topStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            bottomStack.topAnchor.constraint(equalTo: topStack.bottomAnchor, constant: bottomStack.spacing),
            bottomStack.widthAnchor.constraint(equalTo: topStack.widthAnchor),
            bottomStack.heightAnchor.constraint(equalTo: topStack.heightAnchor),
            bottomStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func button(with title: String, id: Int, selector: Selector? = nil) -> Table {
        let button = Table(id: id, name: title)
        guard let selector = selector else { return button }

        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }

    private func blackBackground<T>(_ view: T) -> T where T: UIView {
        view.backgroundColor = .black
        return view
    }
    
    private func redBackground<T>(_ view: T) -> T where T: UIView {
        view.backgroundColor = .red
        return view
    }
    
    private func sized<T>(_ dimension: Double) -> (T) -> T where T: UIView {
        return { (view: T) in
            view.frame.size = CGSize(width: dimension, height: dimension)
            return view
        }
    }
}

class Table: UIButton {
    let name: String
    let id: Int

    init(id: Int, name: String) {
        self.id = id
        self.name = name
        super.init(frame: .zero)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp() {
        setTitle(name, for: .normal)
        setTitleColor(.white, for: .normal)
    }
}
