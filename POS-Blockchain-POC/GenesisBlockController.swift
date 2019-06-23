//
//  GenesisBlockController.swift
//  POS-Blockchain-POC
//
//  Created by Fernando Zanei on 2019-06-22.
//  Copyright © 2019 Jonathan Oliveira. All rights reserved.
//

import MultipeerConnectivity

class Genesis: NSObject {
    
    private let serviceType = "TB-Blockchain"
    private let myPeerId: MCPeerID
    private let service: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    private let sessionInitTime: Date
//    private var isHost: Bool!
//    private var hostId: MCPeerID!
    var isOlder: Bool!
    

    private lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()

    required init(nodeName: String) {
        myPeerId = .init(displayName: nodeName)
        sessionInitTime = Date()
        service = .init(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        browser = .init(peer: myPeerId, serviceType: serviceType)
        super.init()
        service.delegate = self
        service.startAdvertisingPeer()
        browser.delegate = self
        browser.startBrowsingForPeers()
    }
}

extension Genesis: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        var hostTimer = TimeInterval()
        if let context = context {
            hostTimer = context.withUnsafeBytes({ (ptr: UnsafePointer<TimeInterval>) -> TimeInterval in
                return ptr.pointee
            })
        }
        let peerRunningTime = -sessionInitTime.timeIntervalSinceNow
        
        isOlder = (hostTimer > peerRunningTime)

        // note: invitation handler can be used for security reasons
        // true: always accept the connection
        invitationHandler(true, self.session)
        
//        let isHostOlder = (hostTimer > peerRunningTime)
//        if isHostOlder {
//            browser.stopBrowsingForPeers()
//            isHost = false
//            hostID = peerID
//        }
    }
}

extension Genesis: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        var runningTime = -sessionInitTime.timeIntervalSinceNow
        let data = Data(buffer: UnsafeBufferPointer(start: &runningTime, count: 1))
        browser.invitePeer(peerID, to: session, withContext: data, timeout: 20)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
    
}

extension Genesis: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("conectou")
        case .connecting:
            print("conectando")
        default:
            print("desconectou")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {

    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }
    
    
}
