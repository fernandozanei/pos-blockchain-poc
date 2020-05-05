//
//  LocalServer.swift
//  POS-Blockchain-POC
//
//  Created by Jonathan Oliveira on 2020-05-04.
//  Copyright © 2020 Jonathan Oliveira. All rights reserved.
//

import Swifter

final class LocalServer {

    public static var shared: LocalServer = localServer ?? LocalServer()
    private static var localServer: LocalServer?

    private let httpServer: HttpServer
    private var state: State

    private let initialPort: Int = 1337
    private let maxOpenPorts: Int = 5
    private let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)

    private init() {
        httpServer = HttpServer()
        localAddress = PortMapper.localAddress()
        state = .stopped
        LocalServer.localServer = self
        setupEndpoints()
    }

    deinit {
        state = .stopped
        LocalServer.localServer = nil
    }

    let localAddress: String
    var port: Int? { try? httpServer.port() }

    func start() {
        guard state == .stopped else { return }

        if initiateServer(at: initialPort) {
            state = .started
        }
    }

    func stop() {
        state = .stopped
    }

    func broadcast(_ data: Data) {
        for peerPort in initialPort...(initialPort + maxOpenPorts) {
            guard peerPort != port,
                let peerUrl = URL(string: "http://\(localAddress):\(peerPort)") else { continue }

            var request = URLRequest(url: peerUrl.appendingPathComponent("/block"))
            request.httpMethod = "POST"
            let contentLength = String(data.count)
            request.allHTTPHeaderFields = ["Content-Type": "text/plain", "Content-Length": contentLength]
            request.httpBodyStream = InputStream(data: data)
            session.uploadTask(withStreamedRequest: request).resume()
        }
    }
}

private extension LocalServer {
    enum State {
        case started
        case stopped
    }

    func initiateServer(at port: Int) -> Bool {
        guard port < initialPort + maxOpenPorts else { return false }

        do {
            try httpServer.start(in_port_t(port), forceIPv4: true)
        } catch {
            return initiateServer(at: port + 1)
        }

        return true
    }

    func setupEndpoints() {
        httpServer.POST["/block"] = { request in
            let bytes = request.body
            let data = Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
            if let block = try? JSONDecoder().decode(Blockchain.Block.self, from: data) {
                DispatchQueue.main.async {
                    blockchain.append(block: block)
                }
            }

            return HttpResponse.ok(.text("pong!"))
        }
    }
}
