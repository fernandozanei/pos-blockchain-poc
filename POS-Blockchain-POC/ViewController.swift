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
        
        table1 = button(with: PortMapper.localAddress() + ":\(try! server!.port())", id: 1, selector: #selector(pressedAction(_:))) |> blackBackground
        table2 = button(with: "Table 2", id: 2, selector: #selector(pressedAction(_:))) |> blackBackground
        table3 = button(with: "Table 3", id: 3, selector: #selector(pressedAction(_:))) |> blackBackground
        table4 = button(with: "Table 4", id: 4, selector: #selector(pressedAction(_:))) |> blackBackground

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
        let registeredTables = blockchain.listen(for: TableState.self, with: tableListener)
        registeredTables.forEach { tableListener($0) }
//        if let server = server {
//            HttpRequest()
//            server.dispatch(URLRequest(url: URL(string: "192.168.0.15:1337/")!))
////            print(try! server.port())
//        }
	}
    
    @objc func pressedAction(_ sender: UIButton!) {
        guard let table = sender as? Table else { return }
        let isOpen = table.backgroundColor == .black ? true : false
//        let newColor: UIColor = table.backgroundColor == .black ? .red : .black
        blockchain.add(transaction: TableState(number: table.id, isOpen: isOpen))
//        table.backgroundColor = newColor

        let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
//        let defaultLocalhost = URL(string: "http://192.168.0.15:1338")!
//        session.dataTask(with: defaultLocalhost.appendingPathComponent("/ping")) { data, response, error in
//            print(data)
//            print(response)
//            print(error)
//        }.resume()
        let defaultLocalhost = URL(string: "http://192.168.0.15:1338")!
        let data = "Small data".data(using: .utf8)
        var request = URLRequest(url: defaultLocalhost.appendingPathComponent("/test"))
        request.httpMethod = "POST"
        let countString = String(data!.count)
        request.allHTTPHeaderFields = ["Content-Type": "text/plain", "Content-Length": countString]
        //        request.allHTTPHeaderFields = ["Content-Type": "text/plain"]
//        print(countString)
        request.httpBodyStream = InputStream(data: data!)
        /*
         [response setHeaderField:@"Content-Length" value:contentLengthStr];
         NSString *contentTypeStr = [NSString stringWithFormat:@"multipart/byteranges; boundary=%@", ranges_boundry];
         [response setHeaderField:@"Content-Type" value:contentTypeStr];
         */
        //        request.httpBodyStream
        let uploadTask = session.uploadTask(withStreamedRequest: request)
        uploadTask.resume()
//        session.dataUploadTask(with: defaultLocalhost.appendingPathComponent("/ping")) { data, response, error in
//            print(data)
//            print(response)
//            print(error)
//            }.resume()
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
//    func button(with title: String, selector: Selector? = nil) -> UIButton {
//        let button = UIButton()
//        button.setTitle(title, for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        guard let selector = selector else { return button }
//        button.addTarget(self, action: selector, for: .touchUpInside)
//        return button
//    }
    func button(with title: String, id: Int, selector: Selector? = nil) -> Table {
        let button = Table(id: id, name: title)
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

class Table: UIButton {
    let name: String
    let id: Int

    init(id: Int, name: String) {
        self.id = id
        self.name = name
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
