//
//  ViewController.swift
//  POS-Blockchain-POC
//
//  Created by Jonathan Oliveira on 22/06/19.
//  Copyright © 2019 Jonathan Oliveira. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let serverButton: UIButton = {
        let button = UIButton()
        button.setTitle("Init BC", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(newBC), for: .touchUpInside)
        return button
    }()
    
    let clientButton: UIButton = {
        let button = UIButton()
        button.setTitle("Join BC", for: .normal)
        button.backgroundColor = .red
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(joinBC), for: .touchUpInside)
        return button
    }()
    
    @objc func newBC() {
        bc = Blockchain()
        // start multipeer browse
        // segue login
    }
    
    @objc func joinBC() {
        // search and get bc from multipeer
        //segue login
    }

    override func viewDidLoad() {
		super.viewDidLoad()
    
        view.addSubview(serverButton)
        serverButton.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 100, left: 100, bottom: 0, right: 0), size: .init(width: 200, height: 200))
        
        view.addSubview(clientButton)
        clientButton.anchor(top: view.topAnchor, leading: serverButton.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 100, left: 100, bottom: 0, right: 0), size: .init(width: 200, height: 200))
        
        print(uuiID)
        _ = Genesis(nodeName: uuiID)

	}


}

