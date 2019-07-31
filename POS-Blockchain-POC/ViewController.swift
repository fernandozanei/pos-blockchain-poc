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
        
        table1 = button(with: "Table 1", selector: #selector(pressedAction(_:))) |> blackBackground
        table2 = button(with: "Table 2", selector: #selector(pressedAction(_:))) |> blackBackground
        table3 = button(with: "Table 3", selector: #selector(pressedAction(_:))) |> blackBackground
        table4 = button(with: "Table 4", selector: #selector(pressedAction(_:))) |> blackBackground

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
		
/*
         CODE RELATED TO MULTIPEER-CONNECTIVITY
		let nodeUUID = NSUUID().uuidString
        print(nodeUUID)
        _ = Genesis(nodeName: nodeUUID)
 */
	}
    
    @objc func pressedAction(_ sender: UIButton!) {
        let newColor: UIColor = sender.backgroundColor == .black ? .red : .black
        sender.backgroundColor = newColor
    }
}

private extension ViewController {
    func button(with title: String, selector: Selector? = nil) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
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

