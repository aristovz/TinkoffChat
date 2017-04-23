//
//  MultipeerCommunicator.swift
//  TinkoffChat
//
//  Created by Pavel Aristov on 09.04.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol Communicator {
    weak var delegate: CommunicatorDelegate? { get set }
    
    func invitePeer(peer: Peer)
    func sendMessage(string: String, to peer: Peer, completionHandler:((_ success: Bool, _ error: Error?) -> ()))
}

protocol CommunicatorDelegate: class {
    //discovering
    func didFoundUser(peer: MCPeerID, userName: String?)
    func didLostUser(userID: String)
    
    //errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    
    //messages
    func didReceiveMessage(text: String, fromUser: String, toUser: String)
}

class MultipeerCommunicator: NSObject, Communicator {
    private let tinkoffServiceType = "tinkoff-chat"
    
    var peer: MCPeerID!
    
    var advertiser : MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    
    weak var delegate: CommunicatorDelegate?
    
    var sessions = [String: MCSession]()
    
    init(delegate: CommunicatorDelegate) {
        super.init()

        peer = MCPeerID(displayName: UIDevice.current.identifierForVendor!.uuidString)
        
        self.delegate = delegate

        self.advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: ["userName" : Global.currentUser!.name], serviceType: tinkoffServiceType)
        self.advertiser.delegate = self
        
        self.browser = MCNearbyServiceBrowser(peer: peer, serviceType: tinkoffServiceType)
        self.browser.delegate = self
    }
    
    func sendMessage(string: String, to peer: Peer, completionHandler: ((Bool, Error?) -> ())) {
        guard let userID = peer.id else {
            print("Invalid user: \(peer)")
            return
        }
        
        let dict = ["eventType": "TextMessage",
                    "messageId": generateMessageId(),
                    "text": string]
        
        if let currentSession = sessions[userID] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                try currentSession.send(jsonData, toPeers: currentSession.connectedPeers, with: .reliable)
            }
            catch {
                completionHandler(false, error)
            }
        }
        
        completionHandler(true, nil)
    }
    
    func invitePeer(peer: Peer) {
        guard let peerID = peer.peerID else {
            print("Invalid peer: \(peer)")
            return
        }
        
        let session = MCSession(peer: self.peer)
        session.delegate = self
        sessions[peerID.displayName] = session
        
        self.browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }
    
    private func generateMessageId() -> String {
        let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
        
        return string!
    }
}

extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        delegate?.failedToStartAdvertising(error: error)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
 
        let session = MCSession(peer: self.peer, securityIdentity: nil, encryptionPreference: .optional)
        session.delegate = self
        
        sessions[peerID.displayName] = session
        
        invitationHandler(true, session)
    }
}

extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard peerID.displayName != self.peer.displayName else {
            return
        }
        
        delegate?.didFoundUser(peer: peerID, userName: info?["userName"])
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        delegate?.didLostUser(userID: peerID.displayName)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.failedToStartBrowsingForUsers(error: error)
    }
}

extension MultipeerCommunicator: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected to session: \(session)")
            
        case MCSessionState.connecting:
            print("Connecting to session: \(session)")
            
        default:
            print("Did not connect to session: \(session)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let data = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:String]
        
        delegate?.didReceiveMessage(text: data["text"]!, fromUser: peerID.displayName, toUser: "")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) { }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
}


